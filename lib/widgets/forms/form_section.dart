import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class FormSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Column(
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
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Form Fields
        ...children.map((child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          );
        }),
      ],
    );
  }
}
