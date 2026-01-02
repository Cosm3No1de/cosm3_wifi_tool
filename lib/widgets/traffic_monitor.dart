import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrafficMonitor extends StatelessWidget {
  final List<int> latencyHistory;
  final int thresholdMs;
  final int maxPoints;

  const TrafficMonitor({
    super.key,
    required this.latencyHistory,
    this.thresholdMs = 500,
    this.maxPoints = 30,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status based on latest value
    final int currentLatency = latencyHistory.isNotEmpty
        ? latencyHistory.last
        : 0;
    final bool isCritical = currentLatency > thresholdMs;
    final bool isWarning = currentLatency > (thresholdMs * 0.5) && !isCritical;

    Color statusColor = Colors.cyanAccent;
    if (isCritical) {
      statusColor = Colors.redAccent;
    } else if (isWarning) {
      statusColor = Colors.amberAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "REAL-TIME LATENCY",
              style: GoogleFonts.firaCode(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "$currentLatency ms",
                  style: GoogleFonts.firaCode(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (maxPoints - 1).toDouble(),
              minY: 0,
              maxY: (thresholdMs * 1.2)
                  .toDouble(), // Dynamic max Y based on threshold
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(latencyHistory.length, (index) {
                    return FlSpot(
                      index.toDouble(),
                      latencyHistory[index].toDouble(),
                    );
                  }),
                  isCurved: true,
                  color: statusColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: statusColor.withValues(alpha: 0.1),
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.2),
                        statusColor.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Threshold Line
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 500),
                    FlSpot((maxPoints - 1).toDouble(), 500),
                  ],
                  isCurved: false,
                  color: Colors.red.withValues(alpha: 0.3),
                  barWidth: 1,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
