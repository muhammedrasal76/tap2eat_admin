import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

enum BannerType { error, warning, info, success }

class ErrorBannerWidget extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorBannerWidget({
    super.key,
    required this.message,
    this.type = BannerType.error,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            colors.icon,
            color: colors.foreground,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Retry Button
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: colors.foreground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],

          // Dismiss Button
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              color: colors.foreground,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  _BannerColors _getColors() {
    switch (type) {
      case BannerType.error:
        return _BannerColors(
          background: AppColors.error.withOpacity(0.1),
          border: AppColors.error,
          foreground: AppColors.error,
          icon: Icons.error_outline,
        );
      case BannerType.warning:
        return _BannerColors(
          background: AppColors.warning.withOpacity(0.1),
          border: AppColors.warning,
          foreground: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case BannerType.info:
        return _BannerColors(
          background: AppColors.info.withOpacity(0.1),
          border: AppColors.info,
          foreground: AppColors.info,
          icon: Icons.info_outline,
        );
      case BannerType.success:
        return _BannerColors(
          background: AppColors.success.withOpacity(0.1),
          border: AppColors.success,
          foreground: AppColors.success,
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class _BannerColors {
  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;

  _BannerColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });
}
