import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/services/music_storage_service.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DiscoveredDevice {
  final String ipAddress;
  final int port;
  final String alias;
  final String deviceType;
  final String fingerprint;
  final String visibility;
  DateTime lastSeen;

  DiscoveredDevice({
    required this.ipAddress,
    required this.port,
    required this.alias,
    required this.deviceType,
    required this.fingerprint,
    required this.visibility,
  }) : lastSeen = DateTime.now();

  factory DiscoveredDevice.fromJson(Map<String, dynamic> json, String ip) {
    return DiscoveredDevice(
      ipAddress: ip,
      port: json['port'] ?? 53317,
      alias: json['alias'] ?? 'Unknown Device',
      deviceType: json['deviceType'] ?? 'unknown',
      fingerprint: json['fingerprint'] ?? '',
      visibility: json['visibility'] ?? 'everyone',
    );
  }

  Map<String, dynamic> toJson() => {
        'alias': alias,
        'deviceType': deviceType,
        'port': port,
        'fingerprint': fingerprint,
        'visibility': visibility,
      };
}

class PendingTransferRequest {
  final String senderFingerprint;
  final String senderName;
  final String fileName;
  final int fileSize;
  final String title;
  final String artist;
  final Completer<bool> completer;

  PendingTransferRequest({
    required this.senderFingerprint,
    required this.senderName,
    required this.fileName,
    required this.fileSize,
    required this.title,
    required this.artist,
    required this.completer,
  });
}

class SharingService {
  static const int defaultPort = 53317;
  static const String multicastAddress = '224.0.0.167';
  
  final SharedPreferences _prefs = sl<SharedPreferences>();
  
  HttpServer? _httpServer;
  RawDatagramSocket? _udpBroadcastSocket;
  RawDatagramSocket? _udpListenSocket;
  Timer? _broadcastTimer;
  
  final StreamController<DiscoveredDevice> _discoveryController = StreamController<DiscoveredDevice>.broadcast();
  final Map<String, DiscoveredDevice> _discoveredDevices = {};
  
  PendingTransferRequest? _activeIncomingRequest;
  
  Stream<DiscoveredDevice> get onDeviceDiscovered => _discoveryController.stream;
  List<DiscoveredDevice> get discoveredDevicesList => _discoveredDevices.values.toList();
  
  // Get/Set Device sharing alias
  String get deviceAlias {
    final name = _prefs.getString('sharing_device_name');
    if (name != null && name.isNotEmpty) return name;
    
    // Default fallback
    final appSettingsUsername = _prefs.getString('userName');
    if (appSettingsUsername != null && appSettingsUsername.isNotEmpty) {
      return '$appSettingsUsername (Liser)';
    }
    
    return Platform.isIOS ? 'iPhone (Liser)' : 'Android (Liser)';
  }
  
  set deviceAlias(String val) {
    _prefs.setString('sharing_device_name', val);
  }

  // Get/Set Device visibility mode: everyone, known, off
  String get visibility {
    return _prefs.getString('sharing_visibility') ?? 'everyone';
  }
  
  set visibility(String val) {
    _prefs.setString('sharing_visibility', val);
  }

  // Get unique fingerprint for this device
  String get fingerprint {
    var id = _prefs.getString('sharing_device_fingerprint');
    if (id == null) {
      id = const Uuid().v4();
      _prefs.setString('sharing_device_fingerprint', id);
    }
    return id;
  }

  // Get paired devices list: [{'fingerprint': ..., 'name': ...}]
  List<Map<String, String>> get pairedDevices {
    final list = _prefs.getStringList('sharing_paired_devices') ?? [];
    return list.map((e) {
      final decoded = jsonDecode(e) as Map;
      return {
        'fingerprint': decoded['fingerprint']?.toString() ?? '',
        'name': decoded['name']?.toString() ?? '',
      };
    }).toList();
  }

  void pairDevice(String print, String name) {
    final current = pairedDevices;
    if (current.any((e) => e['fingerprint'] == print)) return;
    
    current.add({'fingerprint': print, 'name': name});
    _savePairedDevices(current);
  }

  void unpairDevice(String print) {
    final current = pairedDevices;
    current.removeWhere((e) => e['fingerprint'] == print);
    _savePairedDevices(current);
  }

  bool isPaired(String print) {
    return pairedDevices.any((e) => e['fingerprint'] == print);
  }

  void _savePairedDevices(List<Map<String, String>> list) {
    final stringified = list.map((e) => jsonEncode(e)).toList();
    _prefs.setStringList('sharing_paired_devices', stringified);
  }

  // Helper to fetch local IPv4 address
  Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Start Receiver Mode (starts HTTP server & UDP broadcast response)
  Future<void> startReceiveMode({
    required Function(PendingTransferRequest) onIncomingRequest,
    required Function(double) onTransferProgress,
  }) async {
    if (visibility == 'off') return;
    
    final localIp = await getLocalIpAddress();
    if (localIp == null) return;
    
    // 1. Start HTTP server
    try {
      _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, defaultPort);
      _httpServer!.listen((HttpRequest request) {
        _handleIncomingHttpRequest(request, onIncomingRequest, onTransferProgress);
      });
    } catch (e) {
      // Server bind failed, probably already running
    }

    // 2. Start UDP Responder
    try {
      _udpListenSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, defaultPort, reuseAddress: true);
      _udpListenSocket!.broadcastEnabled = true;
      _udpListenSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpListenSocket!.receive();
          if (datagram != null) {
            final data = utf8.decode(datagram.data);
            try {
              final json = jsonDecode(data);
              if (json['query'] == 'discover') {
                // Sender is looking for receivers, respond with our details
                _sendPresenceBroadcast(datagram.address, datagram.port);
              }
            } catch (e) {
              // Ignore invalid UDP packet
            }
          }
        }
      });
    } catch (e) {
      // UDP listen failed
    }

    // 3. Periodic broadcast to multicast group
    _broadcastTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _sendPresenceBroadcast(InternetAddress(multicastAddress), defaultPort);
      _sendPresenceBroadcast(InternetAddress('255.255.255.255'), defaultPort);
    });
  }

  void _sendPresenceBroadcast(InternetAddress address, int port) {
    if (_udpListenSocket == null || visibility == 'off') return;
    
    final payload = jsonEncode({
      'alias': deviceAlias,
      'deviceType': Platform.isIOS ? 'ios' : 'android',
      'port': defaultPort,
      'fingerprint': fingerprint,
      'visibility': visibility,
    });
    
    try {
      _udpListenSocket!.send(utf8.encode(payload), address, port);
    } catch (e) {
      // Broadcast fail
    }
  }

  void _handleIncomingHttpRequest(
    HttpRequest request,
    Function(PendingTransferRequest) onIncomingRequest,
    Function(double) onTransferProgress,
  ) async {
    final response = request.response;
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', '*');
    
    if (request.method == 'OPTIONS') {
      response.statusCode = HttpStatus.ok;
      await response.close();
      return;
    }

    final path = request.uri.path;
    
    if (path == '/api/handshake') {
      try {
        final bodyString = await utf8.decoder.bind(request).join();
        final body = jsonDecode(bodyString);
        final senderPrint = body['fingerprint'] ?? '';

        // Check visibility
        if (visibility == 'known' && !isPaired(senderPrint)) {
          response.statusCode = HttpStatus.forbidden;
          response.write(jsonEncode({'error': 'Not paired'}));
          await response.close();
          return;
        }

        response.statusCode = HttpStatus.ok;
        response.write(jsonEncode({
          'alias': deviceAlias,
          'fingerprint': fingerprint,
          'isPaired': isPaired(senderPrint),
        }));
      } catch (e) {
        response.statusCode = HttpStatus.internalServerError;
      }
      await response.close();
      
    } else if (path == '/api/send-request') {
      try {
        final bodyString = await utf8.decoder.bind(request).join();
        final body = jsonDecode(bodyString);
        
        final senderPrint = body['senderFingerprint'] ?? '';
        final senderName = body['senderName'] ?? 'Nearby Device';
        final fileName = body['fileName'] ?? 'song.mp3';
        final fileSize = body['fileSize'] ?? 0;
        final title = body['title'] ?? 'Received Song';
        final artist = body['artist'] ?? 'Unknown Artist';

        if (visibility == 'known' && !isPaired(senderPrint)) {
          response.statusCode = HttpStatus.forbidden;
          response.write(jsonEncode({'accepted': false, 'error': 'Not paired'}));
          await response.close();
          return;
        }

        final completer = Completer<bool>();
        _activeIncomingRequest = PendingTransferRequest(
          senderFingerprint: senderPrint,
          senderName: senderName,
          fileName: fileName,
          fileSize: fileSize,
          title: title,
          artist: artist,
          completer: completer,
        );

        // Notify BLOC to show alert dialog
        onIncomingRequest(_activeIncomingRequest!);

        final accepted = await completer.future;
        response.statusCode = HttpStatus.ok;
        response.write(jsonEncode({
          'accepted': accepted,
        }));
      } catch (e) {
        response.statusCode = HttpStatus.internalServerError;
      }
      await response.close();

    } else if (path == '/api/upload') {
      if (_activeIncomingRequest == null) {
        response.statusCode = HttpStatus.forbidden;
        response.write(jsonEncode({'success': false, 'error': 'No request approved'}));
        await response.close();
        return;
      }
      
      try {
        final fileName = Uri.decodeComponent(request.headers.value('File-Name') ?? _activeIncomingRequest!.fileName);
        final fileSize = int.tryParse(request.headers.value('File-Size') ?? '') ?? _activeIncomingRequest!.fileSize;

        final musicDir = await sl<MusicStorageService>().getMusicDirectory();
        
        // Clean file name to prevent directory traversal
        final cleanFileName = p.basename(fileName);
        final targetPath = p.join(musicDir.path, cleanFileName);
        final targetFile = File(targetPath);
        
        final fileSink = targetFile.openWrite();
        int bytesReceived = 0;

        await for (final chunk in request) {
          fileSink.add(chunk);
          bytesReceived += chunk.length;
          if (fileSize > 0) {
            onTransferProgress(bytesReceived / fileSize);
          }
        }
        
        await fileSink.close();
        
        // Re-scan local library to read and cache new track metadata in Hive
        await sl<LibraryRepository>().scanLibrary();

        response.statusCode = HttpStatus.ok;
        response.write(jsonEncode({'success': true}));
        _activeIncomingRequest = null;
      } catch (e) {
        response.statusCode = HttpStatus.internalServerError;
        response.write(jsonEncode({'success': false, 'error': e.toString()}));
      }
      await response.close();
      
    } else {
      response.statusCode = HttpStatus.notFound;
      await response.close();
    }
  }

  // Stop Receiver Mode
  void stopReceiveMode() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    
    _udpListenSocket?.close();
    _udpListenSocket = null;
    
    _httpServer?.close(force: true);
    _httpServer = null;
    
    _activeIncomingRequest = null;
  }

  // Start Discovery Mode (Sender)
  Future<void> startDiscovery() async {
    _discoveredDevices.clear();
    
    final localIp = await getLocalIpAddress();
    if (localIp == null) return;
    
    try {
      _udpBroadcastSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0, reuseAddress: true);
      _udpBroadcastSocket!.broadcastEnabled = true;
      
      _udpBroadcastSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpBroadcastSocket!.receive();
          if (datagram != null) {
            final data = utf8.decode(datagram.data);
            try {
              final json = jsonDecode(data);
              // Ignore our own presence
              if (json['fingerprint'] == fingerprint) return;
              
              final device = DiscoveredDevice.fromJson(json, datagram.address.address);
              _discoveredDevices[device.fingerprint] = device;
              _discoveryController.add(device);
            } catch (e) {
              // Ignore invalid UDP packet
            }
          }
        }
      });

      // Send initial discovery packet
      final queryPacket = jsonEncode({'query': 'discover'});
      try {
        _udpBroadcastSocket!.send(utf8.encode(queryPacket), InternetAddress(multicastAddress), defaultPort);
      } catch (_) {}
      try {
        _udpBroadcastSocket!.send(utf8.encode(queryPacket), InternetAddress('255.255.255.255'), defaultPort);
      } catch (_) {}
      
    } catch (e) {
      // Discovery socket open failed
    }
  }

  // Stop Discovery Mode
  void stopDiscovery() {
    _udpBroadcastSocket?.close();
    _udpBroadcastSocket = null;
    _discoveredDevices.clear();
  }

  // Send Song to target device
  Future<bool> sendSong({
    required DiscoveredDevice target,
    required String filePath,
    required String title,
    required String artist,
    required Function(double) onProgress,
  }) async {
    final url = 'http://${target.ipAddress}:${target.port}';
    
    // 1. Handshake & Pairing Status
    try {
      final hsResponse = await http.post(
        Uri.parse('$url/api/handshake'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'alias': deviceAlias,
          'fingerprint': fingerprint,
        }),
      ).timeout(const Duration(seconds: 5));
      
      if (hsResponse.statusCode != 200) return false;
      final hsJson = jsonDecode(hsResponse.body);
      if (hsJson['isPaired'] == true) {
        pairDevice(target.fingerprint, target.alias);
      }
    } catch (e) {
      return false; // Target unreachable
    }

    // 2. Request Transfer
    final file = File(filePath);
    if (!await file.exists()) return false;
    
    final fileSize = await file.length();
    
    try {
      final reqResponse = await http.post(
        Uri.parse('$url/api/send-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderFingerprint': fingerprint,
          'senderName': deviceAlias,
          'fileName': p.basename(filePath),
          'fileSize': fileSize,
          'title': title,
          'artist': artist,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (reqResponse.statusCode != 200) return false;
      final reqJson = jsonDecode(reqResponse.body);
      if (reqJson['accepted'] != true) return false; // Rejected by user
      
    } catch (e) {
      return false;
    }

    // 3. Upload File Stream
    try {
      final uploadUri = Uri.parse('$url/api/upload');
      final streamedRequest = http.StreamedRequest('POST', uploadUri);
      
      streamedRequest.headers['Content-Type'] = 'application/octet-stream';
      streamedRequest.headers['File-Name'] = Uri.encodeComponent(p.basename(filePath));
      streamedRequest.headers['File-Size'] = fileSize.toString();
      streamedRequest.contentLength = fileSize;

      int bytesSent = 0;
      final progressStream = file.openRead().map((chunk) {
        bytesSent += chunk.length;
        final progress = bytesSent / fileSize;
        onProgress(progress < 1.0 ? progress : 0.99);
        return chunk;
      });
      
      final completer = Completer<bool>();
      
      streamedRequest.sink.addStream(progressStream).then((_) async {
        await streamedRequest.sink.close();
      }).catchError((err) {
        streamedRequest.sink.close();
        completer.complete(false);
      });

      streamedRequest.send().then((response) {
        if (response.statusCode == 200) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      }).catchError((err) {
        completer.complete(false);
      });

      return await completer.future;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    stopReceiveMode();
    stopDiscovery();
    _discoveryController.close();
  }
}
