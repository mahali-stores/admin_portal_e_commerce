import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrderStatusPieChart extends StatelessWidget {
  final Map<String, int> statusData;
  const OrderStatusPieChart({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red, Colors.grey];
    int colorIndex = 0;

    statusData.forEach((status, count) {
      sections.add(PieChartSectionData(
        color: colors[colorIndex % colors.length],
        value: count.toDouble(),
        title: '$count',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      colorIndex++;
    });

    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: statusData.keys.map((status) {
              final index = statusData.keys.toList().indexOf(status);
              return _buildIndicator(status, colors[index % colors.length]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
