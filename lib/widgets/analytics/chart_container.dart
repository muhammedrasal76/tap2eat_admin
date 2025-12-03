import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class ChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final bool isLoading;
  final String? errorMessage;

  const ChartContainer({
    super.key,
    required this.title,
    required this.chart,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            )
          else
            chart,
        ],
      ),
    );
  }
}
