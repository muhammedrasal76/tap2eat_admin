import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showPulse;

  const StatusBadge({
    super.key,
    required this.status,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        _getStatusDisplayName(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (showPulse) {
      return Stack(
        children: [
          badge,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }

    return badge;
  }

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return AppColors.info;
      case 'preparing':
        return AppColors.primary;
      case 'ready':
        return AppColors.success;
      case 'assigned':
      case 'delivering':
        return AppColors.warning;
      case 'delivered':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusDisplayName() {
    return status[0].toUpperCase() + status.substring(1);
  }
}
