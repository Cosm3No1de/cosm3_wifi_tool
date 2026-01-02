import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scanner_red/models/latency_data_model.dart';
import 'package:scanner_red/services/ping_service.dart'; // Importa el umbral y el historial
import 'package:google_fonts/google_fonts.dart';

class TrafficMonitorWidget extends ConsumerWidget {
  const TrafficMonitorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(latencyHistoryProvider);

    // El gráfico debe tener un alto mínimo para ser visible
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black, // Fondo oscuro para estética Neón
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: const Color(0xFF00E676),
          width: 1.0,
        ), // Borde Neón Lima
      ),
      height: 250,
      child: LineChart(_buildChartData(history)),
    );
  }

  LineChartData _buildChartData(List<LatencyData> history) {
    // 1. Convertir el historial a puntos de gráfico
    List<FlSpot> spots = history.asMap().entries.map((entry) {
      // X: índice en el historial (tiempo relativo), Y: latencia
      return FlSpot(entry.key.toDouble(), entry.value.latencyMs.toDouble());
    }).toList();

    // Color principal Neón Cian para la línea
    const Color neonCyan = Color(0xFF18FFFF);
    // Color de alerta Rojo Neón
    const Color neonRed = Color(0xFFFF1744);
    // Color de la línea de umbral (rojo punteado)
    const Color thresholdColor = Color(0xFFFF1744);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(
              0x33FFFFFF,
            ), // Líneas de cuadrícula blancas y transparentes
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Ocultamos el eje X para mantenerlo limpio
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Latencia (ms)',
            style: TextStyle(color: neonCyan, fontSize: 10),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 100, // Intervalo de 100ms
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: GoogleFonts.spaceMono(color: neonCyan, fontSize: 10),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false, // Se usa el borde del Container padre
      ),
      minX: 0,
      maxX: (history.isNotEmpty ? history.length - 1 : 0)
          .toDouble(), // Evitar error si history está vacío
      minY: 0,
      maxY: 400, // Límite superior del gráfico
      // 2. **Línea de Referencia de Umbral:** Dibuja la línea punteada roja en el umbral
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: pingThresholdMs.toDouble(),
            color: thresholdColor,
            strokeWidth: 1.5,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              style: GoogleFonts.spaceMono(color: thresholdColor, fontSize: 10),
              labelResolver: (line) => 'UMBRAL: ${pingThresholdMs}ms',
            ),
          ),
        ],
      ),

      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: neonCyan, // Línea principal Cian
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // 3. **Visualización de la Alerta:** Cambia el color del punto
              if (index < history.length && history[index].isAlert) {
                // Punto Rojo Neón para puntos que superan el umbral
                return FlDotCirclePainter(
                  radius: 4,
                  color: neonRed,
                  strokeWidth: 1,
                  strokeColor: Colors.black,
                );
              }
              // Punto Cian Neón para los puntos normales
              return FlDotCirclePainter(
                radius: 2,
                color: neonCyan,
                strokeWidth: 1,
                strokeColor: Colors.black,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: neonCyan.withValues(
              alpha: 0.1,
            ), // Relleno sutil debajo de la curva
          ),
        ),
      ],
    );
  }
}
