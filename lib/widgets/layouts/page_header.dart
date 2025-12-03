import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: [
          // Leading Widget
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(width: 16),
            Row(
              children: actions!
                  .map((action) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: action,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
