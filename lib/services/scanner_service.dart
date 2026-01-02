import 'dart:async';
import 'package:flutter/foundation.dart';
import 'scanner_helper.dart'
    if (dart.library.io) 'scanner_helper_io.dart'
    if (dart.library.html) 'scanner_helper_web.dart';

class ScannerService {
  // Singleton
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  /// Scans a subnet (e.g., "192.168.1") for active hosts.
  /// Returns a Stream of active IP strings.
  Stream<String> scanSubnet(
    String subnet, {
    void Function(double)? onProgress,
    void Function(String)? onStatus,
  }) async* {
    if (kIsWeb) {
      // Web Mode: Heuristic HTTP Scan
      // Iterate only common Gateways
      final List<String> targetIps = ["192.168.1.1", "192.168.0.1", "10.0.0.1"];

      int total = targetIps.length;
      int processed = 0;

      if (onStatus != null) onStatus("Iniciando escaneo heurístico web...");

      for (final ip in targetIps) {
        if (onStatus != null) onStatus("Verificando posibilidad: $ip");

        final result = await checkHost(ip);
        if (result != null) yield result;

        processed++;
        if (onProgress != null) onProgress(processed / total);

        // Short delay to yield UI
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    final List<String> ipsToScan = [];
    // Generate IPs from 1 to 254
    for (int i = 1; i < 255; i++) {
      ipsToScan.add('$subnet.$i');
    }

    // Batch configs
    const int batchSize = 10;
    const Duration batchDelay = Duration(milliseconds: 100); // Rate Limiting

    // Process in batches
    for (int i = 0; i < ipsToScan.length; i += batchSize) {
      final end = (i + batchSize < ipsToScan.length)
          ? i + batchSize
          : ipsToScan.length;
      final batch = ipsToScan.sublist(i, end);

      // Execute batch in parallel (Future.wait)
      final results = await Future.wait(batch.map((ip) => checkHost(ip)));

      // Yield active hosts
      for (final result in results) {
        if (result != null) {
          yield result;
        }
      }

      // Update progress
      if (onProgress != null) {
        final progress = end / ipsToScan.length;
        onProgress(progress);
      }

      // Throttle/Rate Limiting between batches
      await Future.delayed(batchDelay);
    }
  }
}
