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
  final _formatter = NumberFormat('#,##0', 'id_ID'); // No decimals

  @override
  void initState() {
    super.initState();
    // Format initial value if present
    if (widget.controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formatInput(widget.controller.text, callOnChanged: false);
      });
    }
  }

  void _formatInput(String value, {bool callOnChanged = true}) {
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      widget.controller.clear();
      if (callOnChanged) widget.onChanged?.call('');
      return;
    }

    // Prevent leading zeros
    final normalized = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    final number = int.tryParse(normalized.isEmpty ? '0' : normalized) ?? 0;
    final formatted = _formatter.format(number);

    // Update controller without triggering onChanged during formatting
    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    // Notify parent with unformatted number
    if (callOnChanged) widget.onChanged?.call(number.toString());
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
      onChanged: (val) => _formatInput(val),
      validator: widget.validator,
      enabled: widget.enabled,
    );
  }
}
