import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? helperText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String prefixText;
  final bool enabled;

  const PriceInput({
    super.key,
    required this.controller,
    required this.labelText,
    this.helperText,
    this.onChanged,
    this.validator,
    this.prefixText = 'Rp ',
    this.enabled = true,
  });

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  final _formatter = NumberFormat('#,##0.00', 'id_ID');

  void _formatInput(String value) {
    // Remove all non-digit characters except decimal point
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      widget.controller.clear();
      widget.onChanged?.call('');
      return;
    }

    // Convert to number
    final number = int.parse(digitsOnly);

    // Format with thousand separator and 2 decimal places
    final formatted = _formatter.format(number);

    // Update controller without triggering onChanged during formatting
    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    // Notify parent with unformatted number
    widget.onChanged?.call(digitsOnly);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixText: widget.prefixText,
        helperText: widget.helperText,
      ),
      onChanged: _formatInput,
      validator: widget.validator,
      enabled: widget.enabled,
    );
  }
}
