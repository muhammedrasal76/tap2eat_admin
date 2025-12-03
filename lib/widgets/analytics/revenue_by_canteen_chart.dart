import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/colors.dart';

class RevenueByCanteenChart extends StatelessWidget {
  final Map<String, double> revenueByCanteen;

  const RevenueByCanteenChart({
    super.key,
    required this.revenueByCanteen,
  });

  @override
  Widget build(BuildContext context) {
    if (revenueByCanteen.isEmpty) {
      return Center(
        child: Text(
          'No revenue data available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Sort canteens by revenue (highest to lowest)
    final sortedEntries = revenueByCanteen.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxRevenue = sortedEntries.first.value;
    final safeMaxY = maxRevenue == 0 ? 1000.0 : (maxRevenue * 1.2);

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
                  if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                    final canteenId = sortedEntries[value.toInt()].key;
                    // Extract canteen name or use ID
                    final displayName = _getCanteenDisplayName(canteenId);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
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
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  // Format as ₹Xk for thousands
                  if (value >= 1000) {
                    return Text(
                      '₹${(value / 1000).toStringAsFixed(0)}k',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  } else {
                    return Text(
                      '₹${value.toInt()}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  }
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            sortedEntries.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: sortedEntries[index].value,
                  color: AppColors.primary,
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              tooltipBorder: BorderSide(color: AppColors.borderColor),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final canteenId = sortedEntries[groupIndex].key;
                final revenue = sortedEntries[groupIndex].value;
                final displayName = _getCanteenDisplayName(canteenId);
                return BarTooltipItem(
                  '$displayName\n₹${revenue.toStringAsFixed(2)}',
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

  String _getCanteenDisplayName(String canteenId) {
    // Extract a readable name from canteen ID
    // If canteen ID is like "canteen_1" or just an ID, show a shortened version
    if (canteenId.length > 10) {
      return 'C${canteenId.substring(canteenId.length - 3)}';
    }
    return canteenId;
  }
}
