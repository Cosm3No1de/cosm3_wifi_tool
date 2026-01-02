import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/connections_service.dart';
import '../models/connection_info.dart';

class ConnectionsProvider extends ChangeNotifier {
  final ConnectionsService _service = ConnectionsService();
  Timer? _timer;

  // Expose service state directly
  List<ConnectionInfo> get conexiones => _service.connections;
  bool get cargando => _service.loading;
  String get error => _service.error;

  ConnectionsProvider() {
    // Listen to service changes and propagate them
    _service.addListener(notifyListeners);
    _iniciarMonitoreo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.removeListener(notifyListeners);
    _service.dispose();
    super.dispose();
  }

  void _iniciarMonitoreo() {
    obtenerConexiones();
    // Actualizar cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      obtenerConexiones(silencioso: true);
    });
  }

  Future<void> obtenerConexiones({bool silencioso = false}) async {
    await _service.fetchConnections(silent: silencioso);
  }

  Future<bool> killConnection(ConnectionInfo info) async {
    return await _service.closeConnection(info);
  }
}
