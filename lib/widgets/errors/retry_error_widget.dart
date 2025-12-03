import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class RetryErrorWidget extends StatelessWidget {
  final String message;
  final String? errorDetails;
  final VoidCallback onRetry;
  final IconData icon;

  const RetryErrorWidget({
    super.key,
    required this.message,
    this.errorDetails,
    required this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            Text(
              message,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Error Details
            if (errorDetails != null) ...[
              const SizedBox(height: 8),
              Text(
                errorDetails!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 32),

            // Retry Button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RetryErrorWidget(
      message: 'No Internet Connection',
      errorDetails: 'Please check your network connection and try again',
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }
}
