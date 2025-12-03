import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';

class OrdersOverTimeChart extends StatelessWidget {
  final Map<DateTime, int> ordersByDay;

  const OrdersOverTimeChart({
    super.key,
    required this.ordersByDay,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDates = ordersByDay.keys.toList()..sort();

    if (sortedDates.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final maxY = (ordersByDay.values.reduce((a, b) => a > b ? a : b) * 1.2).ceil();
    final safeMaxY = maxY == 0 ? 10.0 : maxY.toDouble();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
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
                  if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                    final date = sortedDates[value.toInt()];
                    return Text(
                      DateFormat('MMM dd').format(date),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
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
          minX: 0,
          maxX: (sortedDates.length - 1).toDouble(),
          minY: 0,
          maxY: safeMaxY,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                sortedDates.length,
                (index) => FlSpot(
                  index.toDouble(),
                  ordersByDay[sortedDates[index]]!.toDouble(),
                ),
              ),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: AppColors.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              tooltipBorder: BorderSide(color: AppColors.borderColor),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = sortedDates[spot.x.toInt()];
                  return LineTooltipItem(
                    '${DateFormat('MMM dd').format(date)}\n${spot.y.toInt()} orders',
                    TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
