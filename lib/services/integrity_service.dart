import 'integrity_checker.dart'
    if (dart.library.io) 'integrity_checker_io.dart'
    if (dart.library.html) 'integrity_checker_web.dart';

class IntegrityService {
  static Future<bool> checkIntegrity() async {
    return await checkDeviceIntegrity();
  }
}
