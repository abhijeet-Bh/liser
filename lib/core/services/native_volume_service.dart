import 'dart:async';
import 'package:flutter/services.dart';

class NativeVolumeService {
  static const MethodChannel _channel = MethodChannel('liser/volume_control');
  static const EventChannel _eventChannel = EventChannel('liser/volume_events');

  final StreamController<double> _volumeController = StreamController<double>.broadcast();

  NativeVolumeService() {
    _eventChannel.receiveBroadcastStream().listen((volume) {
      if (volume is double) {
        _volumeController.add(volume);
      }
    });
  }

  Stream<double> get volumeStream => _volumeController.stream;

  Future<double> getVolume() async {
    try {
      final double? volume = await _channel.invokeMethod('getVolume');
      return volume ?? 1.0;
    } catch (e) {
      return 1.0;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _channel.invokeMethod('setVolume', {'volume': volume});
    } catch (e) {
      // Ignore
    }
  }

  void dispose() {
    _volumeController.close();
  }
}
