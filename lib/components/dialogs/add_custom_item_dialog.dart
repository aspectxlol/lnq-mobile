import 'package:flutter/material.dart';
import '../../models/order_item_data.dart';
import '../price_input.dart';

class AddCustomItemDialog extends StatefulWidget {
  final void Function(OrderItemData) onAddItem;

  const AddCustomItemDialog({
    Key? key,
    required this.onAddItem,
  }) : super(key: key);

  @override
  State<AddCustomItemDialog> createState() => _AddCustomItemDialogState();
}

class _AddCustomItemDialogState extends State<AddCustomItemDialog> {
  final customNameController = TextEditingController();
  final customPriceController = TextEditingController();
  final customNotesController = TextEditingController();

  @override
  void dispose() {
    customNameController.dispose();
    customPriceController.dispose();
    customNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: customNameController,
              decoration: const InputDecoration(
                labelText: 'Custom Item Name',
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            PriceInput(
              controller: customPriceController,
              labelText: 'Custom Price',
              prefixText: 'Rp ',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: customNotesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = customNameController.text.trim();
            final price =
                int.tryParse(customPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

            if (name.isEmpty || price < 0) return;

            widget.onAddItem(
              OrderItemData.custom(
                customName: name,
                customPrice: price,
                notes: customNotesController.text.trim(),
              ),
            );

            Navigator.pop(context);
          },
          child: const Text('Add Item'),
        ),
      ],
    );
  }
}
