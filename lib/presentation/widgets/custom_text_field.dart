import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.label,
    super.key,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.onChanged,
    this.maxLines = 1,
    this.fillColor,
    this.showBorders = true,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final Color? fillColor;
  final bool showBorders;

  @override
  Widget build(BuildContext context) {
    // Definir bordes según showBorders
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          showBorders
              ? BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              )
              : BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border:
            showBorders
                ? OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                : InputBorder.none,
        enabledBorder: defaultBorder,
        focusedBorder:
            showBorders
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                )
                : InputBorder.none,
        errorBorder:
            showBorders
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
                : InputBorder.none,
        filled: true,
        fillColor: fillColor ?? Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
