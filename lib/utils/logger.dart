import 'package:flutter/foundation.dart';

class Logger {
  static void log(String tag, String message) {
    if (kDebugMode) {
      print("[$tag] $message");
    }
  }

  static void error(String tag, String message, [dynamic error]) {
    if (kDebugMode) {
      print("[$tag] ERROR: $message");
      if (error != null) {
        print("[$tag] DETAILS: $error");
      }
    }
  }
}
