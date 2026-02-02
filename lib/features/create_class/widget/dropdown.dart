import 'package:flutter/material.dart';

class Dropdown<T> extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T)? labelBuilder;
  final bool enabled;

  const Dropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.value,
    this.labelBuilder,
    this.enabled = true,
    this.subLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        // ✅ important
        alignment: AlignmentDirectional.bottomStart,
        initialValue: value,
        icon: Icon(
          Icons.unfold_more_rounded,
          color: Colors.grey.shade400,
          size: 20,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        // Custom decoration to remove the standard underline/box
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              icon,
              color: enabled ? theme.primaryColor : Colors.grey,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: InputBorder.none, // Hide the default border
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(labelBuilder?.call(item) ?? item.toString()),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
