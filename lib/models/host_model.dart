class HostStatus {
  final String ip;
  final bool isAlive;
  final int latencyMs;

  HostStatus({required this.ip, this.isAlive = false, this.latencyMs = -1});

  HostStatus copyWith({String? ip, bool? isAlive, int? latencyMs}) {
    return HostStatus(
      ip: ip ?? this.ip,
      isAlive: isAlive ?? this.isAlive,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }
}
