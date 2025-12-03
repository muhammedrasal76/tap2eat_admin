import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class FormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? hint;

  const FormLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
