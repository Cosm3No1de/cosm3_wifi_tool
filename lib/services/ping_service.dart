import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/host_model.dart';
import '../models/latency_data_model.dart';
import '../utils/ping_helper_web.dart'
    if (dart.library.io) '../utils/ping_helper_io.dart';

// Define el umbral de latencia para la detección de anomalías
const int pingThresholdMs = 200;
// Número de fallos consecutivos antes de disparar una alerta crítica
const int maxFailures = 5;

// --- Proveedores de Riverpod ---
// Provee el StateNotifier para la lógica de ping y seguridad
final pingServiceProvider = StateNotifierProvider<PingService, HostStatus>((
  ref,
) {
  return PingService(ref);
});

// Provee una lista de datos de latencia para el gráfico (se mantiene fuera del StateNotifier para actualizar solo el gráfico)
final latencyHistoryProvider = StateProvider<List<LatencyData>>((ref) => []);

// Provee el estado de alerta global para el banner
final securityAlertProvider = StateProvider<SecurityAlertState>(
  (ref) => SecurityAlertState.normal,
);

// Estado de la Alerta
enum SecurityAlertState { normal, critical }

class PingService extends StateNotifier<HostStatus> {
  final Ref ref;
  final _helper = PingHelper();

  PingService(this.ref)
    : super(HostStatus(ip: '8.8.8.8')); // IP inicial de ejemplo

  Timer? _timer;
  int _failureCounter = 0; // Contador de pings fallidos o lentos
  final int _maxHistory = 50; // Límite de puntos en el gráfico

  // Inicia un monitoreo de ping continuo
  void startMonitoring(String targetIp) {
    // 1. Establece la IP objetivo y reinicia el estado
    state = HostStatus(ip: targetIp);
    _failureCounter = 0;
    ref.read(latencyHistoryProvider.notifier).state = [];
    ref.read(securityAlertProvider.notifier).state = SecurityAlertState.normal;

    // 2. Inicia el temporizador de ping
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _performPing(targetIp);
    });
  }

  // Detiene el monitoreo y limpia recursos
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  // Lógica principal de ejecución de ping
  Future<void> _performPing(String targetIp) async {
    try {
      // **Manejo Asíncrono Robusto:** Encapsulamos la llamada de red.
      final result = await _helper.ping(targetIp);

      final int latency = result.latency;
      final bool success = result.success;

      // Actualiza el estado del host
      if (mounted) {
        state = state.copyWith(isAlive: success, latencyMs: latency);
      }

      // 3. **Lógica de Umbral de Seguridad (Detección de Anomalías):**
      if (success && latency > pingThresholdMs) {
        // Latencia alta detectada
        _failureCounter++;
      } else if (!success || latency == -1) {
        // Ping fallido
        _failureCounter++;
      } else {
        // Latencia normal
        _failureCounter = 0;
      }

      // Disparo de Alerta: Verifica si se alcanzó el umbral crítico
      if (_failureCounter >= maxFailures) {
        // Cambia el estado global a CRITICAL
        ref.read(securityAlertProvider.notifier).state =
            SecurityAlertState.critical;
      } else if (_failureCounter == 0 &&
          ref.read(securityAlertProvider) == SecurityAlertState.critical) {
        // Vuelve a la normalidad si se recupera por 5 pings consecutivos (en la práctica, 0 fallos resetea el contador)
        ref.read(securityAlertProvider.notifier).state =
            SecurityAlertState.normal;
      }

      // 4. Actualiza el historial de latencia para el gráfico
      _updateLatencyHistory(
        latency,
        ref.read(securityAlertProvider) == SecurityAlertState.critical,
      );
    } catch (e) {
      // Manejo de error específico (ej. Host no encontrado o excepción de librería)
      debugPrint('Ping Error: $e'); // Log para depuración
      if (mounted) {
        state = state.copyWith(isAlive: false, latencyMs: -1);
      }

      // En caso de excepción, también aumenta el contador de fallos
      _failureCounter++;
      if (_failureCounter >= maxFailures) {
        ref.read(securityAlertProvider.notifier).state =
            SecurityAlertState.critical;
      }
    }
  }

  // Mantiene un historial de latencia de tamaño fijo
  void _updateLatencyHistory(int latency, bool isAlert) {
    final history = ref.read(latencyHistoryProvider.notifier).state;
    final newEntry = LatencyData(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      latencyMs: latency,
      isAlert:
          isAlert ||
          (latency > pingThresholdMs &&
              latency != -1), // Marca el punto si supera el umbral
    );

    // Crear una nueva lista para asegurar inmutabilidad y notificación
    final newHistory = List<LatencyData>.from(history);

    if (newHistory.length >= _maxHistory) {
      newHistory.removeAt(0); // Elimina el punto más antiguo (FIFO)
    }
    newHistory.add(newEntry);

    // Notifica a Riverpod que el State ha cambiado (importante para StateProvider)
    ref.read(latencyHistoryProvider.notifier).state = newHistory;
  }

  // Limpia el temporizador al eliminar el servicio
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
