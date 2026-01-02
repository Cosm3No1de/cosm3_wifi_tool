import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import '../models/connection_info.dart';

import 'connections_helper_web.dart'
    if (dart.library.io) 'connections_helper_io.dart'
    as connection_helper;

export '../models/connection_info.dart';

class ConnectionsService extends ChangeNotifier {
  static const String _tag = "ConnectionsService";
  static const platform = MethodChannel(
    'com.example.scanner_red/android_tools',
  );

  List<ConnectionInfo> _connections = [];
  bool _loading = false;
  String _error = "";

  List<ConnectionInfo> get connections => _connections;
  bool get loading => _loading;
  String get error => _error;

  Future<void> fetchConnections({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = "";
      notifyListeners();
    }

    try {
      // Delegate to platform specific helper
      _connections = await connection_helper.getConnections();

      if (_connections.isEmpty && !silent) {
        _error = "No active connections found (or platform restricted).";
      }
    } catch (e) {
      _error = "Error fetching connections: $e";
      Logger.error(_tag, "Fetch error", e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> closeConnection(ConnectionInfo info) async {
    final success = await connection_helper.killConnection(info);
    if (success) {
      await fetchConnections(silent: true);
    }
    return success;
  }
}
