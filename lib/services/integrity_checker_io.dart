import 'package:safe_device/safe_device.dart';
import 'package:flutter/foundation.dart';

Future<bool> checkDeviceIntegrity() async {
   try {
      // 1. Check for Root/Jailbreak
      bool isJailBroken = await SafeDevice.isJailBroken;

      if (kDebugMode) {
        print("Integrity Check: Jailbroken=$isJailBroken");
      }

      return isJailBroken;
    } catch (e) {
      debugPrint("Integrity Check Error: $e");
      return false;
    }
}
