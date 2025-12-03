import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final String? hint;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
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

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
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
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class DropdownItem<T> {
  final T value;
  final String label;

  DropdownItem({
    required this.value,
    required this.label,
  });
}
