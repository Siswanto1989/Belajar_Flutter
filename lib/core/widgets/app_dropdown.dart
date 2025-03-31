import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T> items;
  final Function(T?)? onChanged;
  final String Function(T) itemLabel;
  final String? Function(T?)? validator;
  final EdgeInsets margin;
  final bool isExpanded;
  final bool enabled;

  const AppDropdown({
    Key? key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    required this.itemLabel,
    this.validator,
    this.margin = const EdgeInsets.only(bottom: 16.0),
    this.isExpanded = true,
    this.enabled = true,
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
          DropdownButtonFormField<T>(
            value: value,
            hint: hint != null ? Text(hint!) : null,
            decoration: InputDecoration(
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
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[100],
            ),
            isExpanded: isExpanded,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            items: items.map<DropdownMenuItem<T>>((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  style: const TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
