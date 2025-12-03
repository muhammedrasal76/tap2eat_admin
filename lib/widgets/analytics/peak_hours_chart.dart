import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/colors.dart';

class PeakHoursChart extends StatelessWidget {
  final Map<int, int> ordersByHour;

  const PeakHoursChart({
    super.key,
    required this.ordersByHour,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = ordersByHour.values.any((count) => count > 0);

    if (!hasData) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Find max value for Y axis
    final maxOrders = ordersByHour.values.reduce((a, b) => a > b ? a : b);
    final safeMaxY = maxOrders == 0 ? 10.0 : (maxOrders * 1.2);

    // Filter to only show hours with data (or reasonable range like 6am - 10pm)
    final relevantHours = <int>[];
    for (var i = 6; i <= 22; i++) {
      relevantHours.add(i);
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: safeMaxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: safeMaxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderColor,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final hour = value.toInt();
                  if (relevantHours.contains(hour)) {
                    // Show every 2nd hour label to avoid crowding
                    if (hour % 2 == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatHour(hour),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: relevantHours.map((hour) {
            final count = ordersByHour[hour] ?? 0;
            return BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: AppColors.primary,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              tooltipBorder: BorderSide(color: AppColors.borderColor),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final hour = group.x.toInt();
                final count = rod.toY.toInt();
                return BarTooltipItem(
                  '${_formatHour(hour)}\n$count orders',
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
