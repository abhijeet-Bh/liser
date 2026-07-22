import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/sharing/data/services/sharing_service.dart';

part 'sharing_event.dart';
part 'sharing_state.dart';

class SharingBloc extends Bloc<SharingEvent, SharingState> {
  final SharingService _sharingService;
  StreamSubscription<DiscoveredDevice>? _discoverySubscription;

  SharingBloc({required SharingService sharingService})
      : _sharingService = sharingService,
        super(const SharingState()) {
    on<StartDiscovery>(_onStartDiscovery);
    on<StopDiscovery>(_onStopDiscovery);
    on<DeviceDiscovered>(_onDeviceDiscovered);
    on<StartReceiveMode>(_onStartReceiveMode);
    on<StopReceiveMode>(_onStopReceiveMode);
    on<IncomingRequestReceived>(_onIncomingRequestReceived);
    on<RespondToRequest>(_onRespondToRequest);
    on<SendSongRequest>(_onSendSongRequest);
    on<TransferProgressUpdated>(_onTransferProgressUpdated);
    on<ResetSharing>(_onResetSharing);
  }

  void _onStartDiscovery(StartDiscovery event, Emitter<SharingState> emit) async {
    emit(state.copyWith(
      status: SharingStatus.scanning,
      discoveredDevices: [],
      errorMessage: () => null,
      successMessage: () => null,
    ));

    _discoverySubscription?.cancel();
    await _sharingService.startDiscovery();
    
    _discoverySubscription = _sharingService.onDeviceDiscovered.listen((device) {
      add(DeviceDiscovered(device));
    });
  }

  void _onStopDiscovery(StopDiscovery event, Emitter<SharingState> emit) {
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _sharingService.stopDiscovery();
    emit(state.copyWith(status: SharingStatus.idle));
  }

  void _onDeviceDiscovered(DeviceDiscovered event, Emitter<SharingState> emit) {
    final updatedDevices = List<DiscoveredDevice>.from(state.discoveredDevices);
    final index = updatedDevices.indexWhere((d) => d.fingerprint == event.device.fingerprint);
    
    if (index >= 0) {
      updatedDevices[index] = event.device;
    } else {
      updatedDevices.add(event.device);
    }
    
    emit(state.copyWith(discoveredDevices: updatedDevices));
  }

  void _onStartReceiveMode(StartReceiveMode event, Emitter<SharingState> emit) async {
    emit(state.copyWith(
      status: SharingStatus.hosting,
      progress: 0.0,
      errorMessage: () => null,
      successMessage: () => null,
    ));

    await _sharingService.startReceiveMode(
      onIncomingRequest: (request) {
        add(IncomingRequestReceived(request));
      },
      onTransferProgress: (progress) {
        add(TransferProgressUpdated(progress));
      },
    );
  }

  void _onStopReceiveMode(StopReceiveMode event, Emitter<SharingState> emit) {
    _sharingService.stopReceiveMode();
    emit(state.copyWith(
      status: SharingStatus.idle,
      pendingRequest: () => null,
      activeDevice: () => null,
      progress: 0.0,
    ));
  }

  void _onIncomingRequestReceived(IncomingRequestReceived event, Emitter<SharingState> emit) {
    emit(state.copyWith(
      status: SharingStatus.connecting,
      pendingRequest: () => event.request,
      activeDevice: () => DiscoveredDevice(
        ipAddress: '',
        port: SharingService.defaultPort,
        alias: event.request.senderName,
        deviceType: 'unknown',
        fingerprint: event.request.senderFingerprint,
        visibility: 'everyone',
      ),
    ));
  }

  void _onRespondToRequest(RespondToRequest event, Emitter<SharingState> emit) {
    if (state.pendingRequest != null) {
      if (event.accept && event.alwaysTrust) {
        _sharingService.pairDevice(
          state.pendingRequest!.senderFingerprint,
          state.pendingRequest!.senderName,
        );
      }
      state.pendingRequest!.completer.complete(event.accept);
      
      if (event.accept) {
        emit(state.copyWith(status: SharingStatus.transferring, progress: 0.0));
      } else {
        emit(state.copyWith(
          status: SharingStatus.hosting,
          pendingRequest: () => null,
          activeDevice: () => null,
        ));
      }
    }
  }

  void _onSendSongRequest(SendSongRequest event, Emitter<SharingState> emit) async {
    emit(state.copyWith(
      status: SharingStatus.connecting,
      activeDevice: () => event.target,
      progress: 0.0,
      errorMessage: () => null,
      successMessage: () => null,
    ));

    final success = await _sharingService.sendSongs(
      target: event.target,
      songs: event.songs,
      onProgress: (progress) {
        add(TransferProgressUpdated(progress));
      },
    );

    if (success) {
      emit(state.copyWith(
        status: SharingStatus.success,
        progress: 1.0,
        successMessage: () => event.songs.length == 1
            ? 'Song sent successfully to ${event.target.alias}!'
            : '${event.songs.length} songs sent successfully to ${event.target.alias}!',
      ));
    } else {
      emit(state.copyWith(
        status: SharingStatus.error,
        errorMessage: () => 'Failed to send songs. The request might have been declined or connection timed out.',
      ));
    }
  }

  void _onTransferProgressUpdated(TransferProgressUpdated event, Emitter<SharingState> emit) {
    if (event.progress >= 1.0) {
      emit(state.copyWith(
        status: SharingStatus.success,
        progress: 1.0,
        successMessage: () => state.status == SharingStatus.transferring 
            ? 'Song received successfully!' 
            : 'Song sent successfully!',
      ));
    } else {
      emit(state.copyWith(
        status: SharingStatus.transferring,
        progress: event.progress,
      ));
    }
  }

  void _onResetSharing(ResetSharing event, Emitter<SharingState> emit) {
    _sharingService.stopDiscovery();
    _sharingService.stopReceiveMode();
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    
    emit(const SharingState());
  }

  @override
  Future<void> close() {
    _discoverySubscription?.cancel();
    _sharingService.dispose();
    return super.close();
  }
}
