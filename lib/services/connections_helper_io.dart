import 'dart:io';
import '../models/connection_info.dart';
import '../utils/logger.dart';

const String _tag = "ConnectionsHelperIO";

Future<List<ConnectionInfo>> getConnections() async {
  if (Platform.isAndroid) {
    // Android logic stub
    // In a real refactor, we'd move the parsing logic here too.
    throw Exception("Android restrictions prevent full connection listing without root.");
  } else if (Platform.isWindows) {
    return await _getDesktopConnections();
  }
  throw Exception("Platform not supported for deep connection analysis.");
}

Future<bool> killConnection(ConnectionInfo info) async {
  if (!Platform.isWindows) return false;

  try {
    final result = await Process.run('taskkill', ['/F', '/PID', info.pid]);
    if (result.exitCode == 0) {
      return true;
    }
    Logger.error(_tag, "Taskkill failed: ${result.stderr}");
    return false;
  } catch (e) {
    Logger.error(_tag, "Taskkill exception", e);
    return false;
  }
}

Future<List<ConnectionInfo>> _getDesktopConnections() async {
  try {
    final pidMap = await _getProcessNames();
    final result = await Process.run('netstat', ['-ano']);

    if (result.stdout.toString().isNotEmpty) {
      final lines = result.stdout.toString().split('\n');
      final List<ConnectionInfo> parsed = [];

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 4 && (parts[0] == 'TCP' || parts[0] == 'UDP')) {
          String protocol = parts[0];
          String local = parts[1];
          String foreign = parts[2];
          String state = "UNKNOWN";
          String pid = "?";

          if (protocol == 'TCP') {
            if (parts.length >= 5) {
              state = parts[3];
              pid = parts.length > 4 ? parts[4] : "?";
            }
          } else {
            state = "N/A";
            pid = parts.length > 3 ? parts[3] : "?";
          }

          String pName = pidMap[pid] ?? "Unknown";
          parsed.add(
            ConnectionInfo(
              protocol: protocol,
              localAddress: local,
              foreignAddress: foreign,
              state: state,
              pid: pid,
              processName: pName,
            ),
          );
        }
      }
      return parsed;
    }
    return [];
  } catch (e) {
    Logger.error(_tag, "Desktop fetch error", e);
    rethrow;
  }
}

Future<Map<String, String>> _getProcessNames() async {
  final Map<String, String> pidToName = {};
  try {
    final result = await Process.run('tasklist', ['/FO', 'CSV', '/NH']);
    if (result.stdout.toString().isNotEmpty) {
      final lines = result.stdout.toString().split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;
        final parts = line.split('","');
        if (parts.length >= 2) {
          String name = parts[0].replaceAll('"', '');
          String pid = parts[1].replaceAll('"', '');
          pidToName[pid] = name;
        }
      }
    }
  } catch (e) {
    Logger.error(_tag, "Tasklist error", e);
  }
  return pidToName;
}
