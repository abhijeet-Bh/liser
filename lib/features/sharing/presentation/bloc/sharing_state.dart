part of 'sharing_bloc.dart';

enum SharingStatus {
  idle,
  scanning,
  hosting,
  connecting,
  transferring,
  success,
  error
}

class SharingState extends Equatable {
  final SharingStatus status;
  final List<DiscoveredDevice> discoveredDevices;
  final PendingTransferRequest? pendingRequest;
  final double progress;
  final DiscoveredDevice? activeDevice;
  final String? errorMessage;
  final String? successMessage;

  const SharingState({
    this.status = SharingStatus.idle,
    this.discoveredDevices = const [],
    this.pendingRequest,
    this.progress = 0.0,
    this.activeDevice,
    this.errorMessage,
    this.successMessage,
  });

  SharingState copyWith({
    SharingStatus? status,
    List<DiscoveredDevice>? discoveredDevices,
    PendingTransferRequest? Function()? pendingRequest,
    double? progress,
    DiscoveredDevice? Function()? activeDevice,
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return SharingState(
      status: status ?? this.status,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      pendingRequest: pendingRequest != null ? pendingRequest() : this.pendingRequest,
      progress: progress ?? this.progress,
      activeDevice: activeDevice != null ? activeDevice() : this.activeDevice,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        discoveredDevices,
        pendingRequest,
        progress,
        activeDevice,
        errorMessage,
        successMessage,
      ];
}
