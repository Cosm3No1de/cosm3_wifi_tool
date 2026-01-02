import 'dart:async';
import '../models/port_result.dart';

import 'port_service_helper_web.dart'
    if (dart.library.io) 'port_service_helper_io.dart';

export '../models/port_result.dart';

class PortService {
  final _helper = PortServiceHelper();

  Stream<PortResult> scanPorts(String ip, {int start = 1, int end = 1000}) {
    return _helper.scanPorts(ip, start, end);
  }

  bool isSSHOpen(List<PortResult> results) {
    return results.any((r) => r.port == 22 && r.isOpen);
  }
}
