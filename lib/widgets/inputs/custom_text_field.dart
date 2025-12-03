import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final String? helperText;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.errorText,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
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
        const SizedBox(height: 8),

        // Text Field
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
            errorText: errorText,
            helperText: helperText,
            helperStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            errorStyle: TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
            counterStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
