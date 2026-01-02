import 'dart:async';
import 'package:flutter/material.dart';

class AuditHelper {
  Future<void> checkPort(
      String ip, int port, Function(String banner) onBanner, Function() onDone) async {
    // Stub for Web
    onDone();
  }

  Future<void> sendWol(String mac) async {
    // Stub
  }
}
