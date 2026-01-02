import 'dart:async';
import 'package:scanner_red/models/port_result.dart';

class PortServiceHelper {
  Stream<PortResult> scanPorts(String ip, int start, int end) async* {
    yield* const Stream.empty();
  }
}
