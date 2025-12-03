import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';

class PriceInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final double? minValue;
  final double? maxValue;
  final String? hint;
  final bool enabled;

  const PriceInputField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.isRequired = false,
    this.minValue,
    this.maxValue,
    this.hint,
    this.enabled = true,
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

        // Input Field
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint ?? '0.00',
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
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
          ),
        ),
      ],
    );
  }
}
