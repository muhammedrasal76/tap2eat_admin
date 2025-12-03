import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/colors.dart';

class OrderTypePieChart extends StatelessWidget {
  final Map<String, int> ordersByType;

  const OrderTypePieChart({
    super.key,
    required this.ordersByType,
  });

  @override
  Widget build(BuildContext context) {
    final pickup = ordersByType['pickup'] ?? 0;
    final delivery = ordersByType['delivery'] ?? 0;
    final total = pickup + delivery;

    if (total == 0) {
      return Center(
        child: Text(
          'No orders yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: pickup.toDouble(),
                    title: '${((pickup / total) * 100).toStringAsFixed(1)}%',
                    color: AppColors.primary,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  PieChartSectionData(
                    value: delivery.toDouble(),
                    title: '${((delivery / total) * 100).toStringAsFixed(1)}%',
                    color: AppColors.warning,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Pickup', pickup, AppColors.primary),
                const SizedBox(height: 12),
                _buildLegendItem('Delivery', delivery, AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
