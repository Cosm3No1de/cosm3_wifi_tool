import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class AuditHelper {
  Future<void> checkPort(
      String ip, int port, Function(String banner) onBanner, Function() onDone) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: 500),
      );

      String banner = "";
      Completer<String> bannerCompleter = Completer<String>();

      socket.listen(
        (data) {
          if (!bannerCompleter.isCompleted) {
            try {
              String raw = String.fromCharCodes(data).trim();
              banner = raw
                  .split('\n')
                  .first
                  .replaceAll(RegExp(r'[^\x20-\x7E]'), '');
              if (banner.length > 50) {
                banner = "${banner.substring(0, 50)}...";
              }
              bannerCompleter.complete(banner);
            } catch (e) {
              debugPrint('Error: $e');
            }
          }
        },
        onError: (e) {
          if (!bannerCompleter.isCompleted) bannerCompleter.complete("");
        },
        onDone: () {
          if (!bannerCompleter.isCompleted) bannerCompleter.complete("");
        },
      );

      // Active Probe
      if (port == 80 || port == 8080 || port == 443) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!bannerCompleter.isCompleted) {
            try {
              socket?.write(
                "HEAD / HTTP/1.1\r\nHost: $ip\r\n\r\n",
              );
            } catch (e) {
              debugPrint('Active probe error: $e');
            }
          }
        });
      }

      try {
        banner = await bannerCompleter.future.timeout(
          const Duration(milliseconds: 1500),
        );
      } catch (e) {
        // Timeout
      }
      
      onBanner(banner);

    } catch (e) {
      // Error
    } finally {
      try {
        socket?.destroy();
      } catch (e) {
        debugPrint('Destroy error: $e');
      }
      onDone();
    }
  }

  Future<void> sendWol(String mac) async {
    try {
      RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
        socket.broadcastEnabled = true;
        List<int> p = [];
        for (int i = 0; i < 6; i++) {
          p.add(0xFF);
        }
        List<String> parts = mac.contains(":")
            ? mac.split(":")
            : mac.split("-");
        for (int i = 0; i < 16; i++) {
          for (var part in parts) {
            p.add(int.parse(part, radix: 16));
          }
        }
        socket.send(p, InternetAddress("255.255.255.255"), 9);
        socket.close();
      });
    } catch (e) {
      debugPrint("WOL Error: $e");
      rethrow;
    }
  }
}
