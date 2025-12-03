import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

enum ButtonVariant { primary, secondary, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: colors.background.withOpacity(0.5),
          disabledForegroundColor: colors.foreground.withOpacity(0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: variant == ButtonVariant.secondary
                ? BorderSide(color: AppColors.borderColor)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          background: AppColors.primary,
          foreground: AppColors.base,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.surface,
          foreground: AppColors.textPrimary,
        );
      case ButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.error,
          foreground: Colors.white,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;

  _ButtonColors({
    required this.background,
    required this.foreground,
  });
}
