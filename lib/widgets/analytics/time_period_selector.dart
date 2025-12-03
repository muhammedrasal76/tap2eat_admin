import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/analytics_time_period.dart';

class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final Function(DateRange) onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.base,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(context, 'Today', TimePeriod.today),
          _buildTab(context, 'This Week', TimePeriod.thisWeek),
          _buildTab(context, 'This Month', TimePeriod.thisMonth),
          _buildTab(context, 'Custom', TimePeriod.custom),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, TimePeriod period) {
    final isSelected = selectedPeriod == period;
    return InkWell(
      onTap: () {
        if (period == TimePeriod.custom) {
          _showCustomDatePicker(context);
        } else {
          final range = period == TimePeriod.today
              ? DateRange.today()
              : period == TimePeriod.thisWeek
                  ? DateRange.thisWeek()
                  : DateRange.thisMonth();
          onPeriodChanged(range);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      onPeriodChanged(DateRange.custom(range.start, range.end));
    }
  }
}
