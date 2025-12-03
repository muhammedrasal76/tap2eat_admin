import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'shimmer_widget.dart';

class TableRowSkeleton extends StatelessWidget {
  final int columns;

  const TableRowSkeleton({
    super.key,
    this.columns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: List.generate(
          columns,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ShimmerWidget(
                width: double.infinity,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      width: 150,
                      height: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    ShimmerWidget(
                      width: 200,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              ShimmerWidget(
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderColor),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ShimmerWidget(
                      width: 40,
                      height: 40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget(
                          width: 100,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 6),
                        ShimmerWidget(
                          width: 80,
                          height: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ShimmerWidget(
                width: 100,
                height: 36,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              ShimmerWidget(
                width: 120,
                height: 40,
                borderRadius: BorderRadius.circular(8),
              ),
              const Spacer(),
              ShimmerWidget(
                width: 140,
                height: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
