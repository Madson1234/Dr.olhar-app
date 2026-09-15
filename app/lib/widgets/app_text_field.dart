import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// 56px-tall labelled text field matching the design's field styling —
/// 1.5px border, 12px radius, focus ring in accent blue, error state in red
/// with a message underneath.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool monospace;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.monospace = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.ps(12, weight: FontWeight.w600, color: AppColors.mut)),
        const SizedBox(height: 7),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: monospace ? AppText.mono(16, weight: FontWeight.w500) : AppText.ps(16, weight: FontWeight.w500),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surf,
              hintText: hint,
              hintStyle: monospace
                  ? AppText.mono(16, weight: FontWeight.w500, color: AppColors.mut)
                  : AppText.ps(16, weight: FontWeight.w500, color: AppColors.mut),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
                borderSide: BorderSide(color: hasError ? AppColors.bad : AppColors.line, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
                borderSide: BorderSide(color: hasError ? AppColors.bad : AppColors.line, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
                borderSide: BorderSide(color: hasError ? AppColors.bad : AppColors.acc, width: 1.5),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: AppText.ps(11.5, weight: FontWeight.w500, color: AppColors.bad)),
        ],
      ],
    );
  }
}
