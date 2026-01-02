class LatencyData {
  final int timestamp;
  final int latencyMs;
  final bool isAlert;

  LatencyData({
    required this.timestamp,
    required this.latencyMs,
    required this.isAlert,
  });
}
