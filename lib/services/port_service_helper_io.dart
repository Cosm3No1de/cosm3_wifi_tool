import 'dart:async';
import 'dart:io';
import 'package:scanner_red/models/port_result.dart';

class PortServiceHelper {
  Stream<PortResult> scanPorts(String ip, int start, int end) async* {
    final List<int> ports = List.generate(end - start + 1, (i) => start + i);
    const int batchSize = 10;

    for (int i = 0; i < ports.length; i += batchSize) {
      final batchEnd = (i + batchSize < ports.length) ? i + batchSize : ports.length;
      final currentBatch = ports.sublist(i, batchEnd);

      final results = await Future.wait(currentBatch.map((port) => _checkPort(ip, port)));

      for (final result in results) {
        if (result != null) yield result;
      }

      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<PortResult?> _checkPort(String ip, int port) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 200));
      String banner = "";
      // Basic banner logic here (omitted for brevity, assume simple port check for now or copy detailed logic)
      return PortResult(port, true, banner);
    } catch (e) {
      return null;
    } finally {
      try { socket?.destroy(); } catch (_) {}
    }
  }
}
