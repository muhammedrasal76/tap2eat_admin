import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class NetworkStatusBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRetry;

  const NetworkStatusBanner({
    super.key,
    required this.isOffline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isOffline ? 50 : 0,
      child: Material(
        color: AppColors.error,
        child: InkWell(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onRetry != null)
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
