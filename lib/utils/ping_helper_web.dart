import 'dart:math';
import '../models/simple_ping_result.dart';

class PingHelper {
  final _random = Random();

  Future<SimplePingResult> ping(String ip) async {
    // Simulate latency between 20ms and 100ms
    final delay = 20 + _random.nextInt(80);
    await Future.delayed(Duration(milliseconds: delay));
    return SimplePingResult(latency: delay, success: true);
  }
}
