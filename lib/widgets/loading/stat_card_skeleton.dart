import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'shimmer_widget.dart';

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

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
          Row(
            children: [
              ShimmerWidget(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(8),
              ),
              const Spacer(),
              ShimmerWidget(
                width: 60,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerWidget(
            width: 100,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          ShimmerWidget(
            width: 140,
            height: 28,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
