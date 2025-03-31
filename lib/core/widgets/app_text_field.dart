import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets margin;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onChanged,
    this.inputFormatters,
    this.margin = const EdgeInsets.only(bottom: 16.0),
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 8.0),
          ],
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: maxLines,
            minLines: minLines,
            onChanged: onChanged,
            focusNode: focusNode,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  // Factory constructor for number field
  factory AppTextField.number({
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    EdgeInsets margin = const EdgeInsets.only(bottom: 16.0),
    FocusNode? focusNode,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      onChanged: onChanged,
      margin: margin,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
    );
  }

  // Factory constructor for integer field
  factory AppTextField.integer({
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    EdgeInsets margin = const EdgeInsets.only(bottom: 16.0),
    FocusNode? focusNode,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
      margin: margin,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  // Factory constructor for multiline text field
  factory AppTextField.multiline({
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    int minLines = 3,
    int maxLines = 5,
    EdgeInsets margin = const EdgeInsets.only(bottom: 16.0),
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    FocusNode? focusNode,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.multiline,
      enabled: enabled,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      margin: margin,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
    );
  }
}
