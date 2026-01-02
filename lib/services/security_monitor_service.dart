import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dart_ping/dart_ping.dart';

// Enum para el estado de seguridad global
enum SecurityState { normal, critical }

class MonitorStats {
  final int latencyMs;
  final bool isAnomaly;
  final SecurityState securityState;

  MonitorStats({
    required this.latencyMs,
    required this.isAnomaly,
    required this.securityState,
  });
}

class SecurityMonitorService {
  // Singleton pattern
  static final SecurityMonitorService _instance =
      SecurityMonitorService._internal();
  factory SecurityMonitorService() => _instance;
  SecurityMonitorService._internal();

  Ping? _ping;
  final _controller = StreamController<MonitorStats>.broadcast();
  Stream<MonitorStats> get statsStream => _controller.stream;

  // Configuración de Seguridad
  static const int _anomalyThresholdMs =
      200; // Umbral reducido a 200ms como solicitado
  static const String _target = '8.8.8.8'; // Google DNS
  static const int _strikeLimit =
      5; // Número de pings anómalos para activar alerta

  // Estado Interno
  int _consecutiveAnomalies = 0;
  int _consecutiveNormals = 0;
  SecurityState _currentSecurityState = SecurityState.normal;

  void startMonitoring() {
    stopMonitoring(); // Asegurar que no haya duplicados

    if (kIsWeb) {
      // Web Mode: Simulate monitoring
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_controller.isClosed) {
          timer.cancel();
          return;
        }
        // Simulate normal latency
        _processPingResult(20 + (DateTime.now().millisecond % 50));
      });
      return;
    }

    // Ejecuta un ping cada 2 segundos para mayor resolución
    _ping = Ping(_target, interval: 2);

    _ping!.stream.listen((event) {
      if (event.response != null && event.response!.time != null) {
        final latency = event.response!.time!.inMilliseconds;
        _processPingResult(latency);
      } else if (event.error != null) {
        // Error de conexión cuenta como latencia máxima
        _processPingResult(999);
      }
    });
  }

  void _processPingResult(int latency) {
    final isAnomaly = latency > _anomalyThresholdMs;

    if (isAnomaly) {
      _consecutiveAnomalies++;
      _consecutiveNormals = 0; // Reset contador normal
    } else {
      _consecutiveNormals++;
      _consecutiveAnomalies = 0; // Reset contador anomalía
    }

    // Lógica de Cambio de Estado (Máquina de Estados)
    if (_currentSecurityState == SecurityState.normal) {
      if (_consecutiveAnomalies >= _strikeLimit) {
        _currentSecurityState = SecurityState.critical;
        // Podríamos notificar un servicio de logs aquí
      }
    } else if (_currentSecurityState == SecurityState.critical) {
      if (_consecutiveNormals >= _strikeLimit) {
        _currentSecurityState = SecurityState.normal;
      }
    }

    // Emitir nuevo estado
    _controller.add(
      MonitorStats(
        latencyMs: latency,
        isAnomaly: isAnomaly,
        securityState: _currentSecurityState,
      ),
    );
  }

  void stopMonitoring() {
    _ping?.stop();
    _ping = null;
    _consecutiveAnomalies = 0;
    _consecutiveNormals = 0;
    _currentSecurityState = SecurityState.normal;
  }

  void dispose() {
    stopMonitoring();
    _controller.close();
  }
}
