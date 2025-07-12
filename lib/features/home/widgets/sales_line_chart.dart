import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesLineChart extends StatelessWidget {
  final Map<DateTime, double> salesData;
  const SalesLineChart({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    // Prepare data points for the chart
    final List<FlSpot> spots = [];
    final List<DateTime> sortedKeys = salesData.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      final date = sortedKeys[i];
      final sales = salesData[date]!;
      spots.add(FlSpot(i.toDouble(), sales));
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < sortedKeys.length) {
                    final date = sortedKeys[value.toInt()];
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(DateFormat.E().format(date)), // e.g., "Mon"
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
