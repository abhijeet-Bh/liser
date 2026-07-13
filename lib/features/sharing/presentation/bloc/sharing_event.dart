part of 'sharing_bloc.dart';

sealed class SharingEvent extends Equatable {
  const SharingEvent();

  @override
  List<Object?> get props => [];
}

class StartDiscovery extends SharingEvent {}

class StopDiscovery extends SharingEvent {}

class DeviceDiscovered extends SharingEvent {
  final DiscoveredDevice device;
  const DeviceDiscovered(this.device);

  @override
  List<Object?> get props => [device];
}

class StartReceiveMode extends SharingEvent {}

class StopReceiveMode extends SharingEvent {}

class IncomingRequestReceived extends SharingEvent {
  final PendingTransferRequest request;
  const IncomingRequestReceived(this.request);

  @override
  List<Object?> get props => [request];
}

class RespondToRequest extends SharingEvent {
  final bool accept;
  final bool alwaysTrust;

  const RespondToRequest({required this.accept, required this.alwaysTrust});

  @override
  List<Object?> get props => [accept, alwaysTrust];
}

class SendSongRequest extends SharingEvent {
  final DiscoveredDevice target;
  final String filePath;
  final String title;
  final String artist;

  const SendSongRequest({
    required this.target,
    required this.filePath,
    required this.title,
    required this.artist,
  });

  @override
  List<Object?> get props => [target, filePath, title, artist];
}

class TransferProgressUpdated extends SharingEvent {
  final double progress;
  const TransferProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ResetSharing extends SharingEvent {}
