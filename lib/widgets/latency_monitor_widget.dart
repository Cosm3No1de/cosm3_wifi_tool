import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/security_monitor_service.dart';
import '../theme.dart';

class LatencyMonitorWidget extends StatefulWidget {
  const LatencyMonitorWidget({super.key});

  @override
  State<LatencyMonitorWidget> createState() => _LatencyMonitorWidgetState();
}

class _LatencyMonitorWidgetState extends State<LatencyMonitorWidget> {
  final List<FlSpot> _spots = [];
  final int _maxPoints = 30; // Aumentado para ver más historia
  double _currentLatency = 0;
  bool _isAnomaly = false;
  SecurityState _securityState = SecurityState.normal;

  @override
  void initState() {
    super.initState();
    // Suscribirse al stream de seguridad
    SecurityMonitorService().statsStream.listen((stats) {
      if (!mounted) return;
      setState(() {
        _currentLatency = stats.latencyMs.toDouble();
        _isAnomaly = stats.isAnomaly;
        _securityState = stats.securityState;

        // Añadir nuevo punto (X = tiempo actual)
        _spots.add(
          FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(),
            _currentLatency,
          ),
        );

        // Mantener solo los últimos _maxPoints
        if (_spots.length > _maxPoints) {
          _spots.removeAt(0);
        }
      });
    });
  }

  Color _getLineColor() {
    if (_securityState == SecurityState.critical) {
      return Colors.redAccent; // Rojo Neón para estado crítico
    }
    return _isAnomaly ? Colors.amber : AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final bool isCritical = _securityState == SecurityState.critical;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? Colors.redAccent
              : AppTheme.primary.withValues(alpha: 0.3),
          width: isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCritical
                ? Colors.redAccent.withValues(alpha: 0.2)
                : AppTheme.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCritical ? Icons.warning_amber_rounded : Icons.show_chart,
                    color: isCritical ? Colors.redAccent : AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "LATENCIA DE RED (ms)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'Courier', // Space Mono si estuviera disponible
                    ),
                  ),
                ],
              ),
              Text(
                "${_currentLatency.toStringAsFixed(0)} ms",
                style: TextStyle(
                  color: _isAnomaly
                      ? Colors.amber
                      : (isCritical ? Colors.redAccent : AppTheme.primary),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: _spots.isEmpty
                ? const Center(
                    child: Text(
                      "Iniciando monitor...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withValues(alpha: 0.05),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: _spots.first.x,
                      maxX: _spots.last.x,
                      minY: 0,
                      maxY: 600,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: true,
                          color: _getLineColor(),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) {
                              // Mostrar puntos solo si superan el umbral (200ms)
                              return spot.y > 200;
                            },
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors
                                    .redAccent, // Puntos rojos para anomalías
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _getLineColor().withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      // Línea de umbral
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 200, // Umbral de anomalía actualizado
                            color: Colors.red.withValues(alpha: 0.5),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              labelResolver: (line) => 'UMBRAL (200ms)',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
