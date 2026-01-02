import 'package:dart_ping/dart_ping.dart';
import '../models/simple_ping_result.dart';

class PingHelper {
  Future<SimplePingResult> ping(String ip) async {
    try {
      final ping = Ping(ip, count: 1, timeout: 2);
      final result = await ping.stream.first;
      final int latency = result.response?.time?.inMilliseconds ?? -1;
      final bool success = result.response != null;
      return SimplePingResult(latency: latency, success: success);
    } catch (e) {
      return SimplePingResult(latency: -1, success: false);
    }
  }
}
