import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  
  const PerformanceChart({
    super.key,
    required this.chartData,
  });
  
  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text('No data available yet. Take a quiz to see your progress!'),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return Text(
                      'Q${index + 1}',
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[400]!, width: 1),
              left: BorderSide(color: Colors.grey[400]!, width: 1),
            ),
          ),
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // Mathematics line
            _createLineChartBarData(
              AppConstants.mathSubject,
              AppConstants.mathColor,
            ),
            // Reasoning line
            _createLineChartBarData(
              AppConstants.reasoningSubject,
              AppConstants.reasoningColor,
            ),
            // VARC line
            _createLineChartBarData(
              AppConstants.varcSubject,
              AppConstants.varcColor,
            ),
          ],
        ),
      ),
    );
  }
  
  LineChartBarData _createLineChartBarData(String subject, Color color) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < chartData.length; i++) {
      final value = chartData[i][subject] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          AppConstants.mathSubject,
          AppConstants.mathColor,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          AppConstants.reasoningSubject,
          AppConstants.reasoningColor,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          AppConstants.varcSubject,
          AppConstants.varcColor,
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _abbreviateSubject(label),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  String _abbreviateSubject(String subject) {
    if (subject.contains('Mathematics')) return 'Math';
    if (subject.contains('Logical')) return 'Reasoning';
    if (subject.contains('Verbal Ability')) return 'Verbal Ability';
    return subject;
  }
}
