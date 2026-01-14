import 'package:flutter/material.dart';
import '../../l10n/strings.dart';

/// Reusable sort and filter dialog for screens
class SortFilterDialog extends StatefulWidget {
  final String initialSortField;
  final bool initialSortAscending;
  final List<Map<String, String>> sortOptions;
  final void Function(String sortField, bool sortAscending) onApply;
  final bool showDateRange;
  final DateTimeRange? initialDateRange;
  final void Function(DateTimeRange?)? onDateRangeChanged;

  const SortFilterDialog({
    super.key,
    required this.initialSortField,
    required this.initialSortAscending,
    required this.sortOptions,
    required this.onApply,
    this.showDateRange = false,
    this.initialDateRange,
    this.onDateRangeChanged,
  });

  @override
  State<SortFilterDialog> createState() => _SortFilterDialogState();
}

class _SortFilterDialogState extends State<SortFilterDialog> {
  late String _sortField;
  late bool _sortAscending;
  late DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _sortField = widget.initialSortField;
    _sortAscending = widget.initialSortAscending;
    _dateRange = widget.initialDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.tr(context, 'sortAndFilter'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              if (widget.showDateRange) ...[
                _buildDateRangeSelector(context),
                const SizedBox(height: 20),
              ],
              _buildSortByDropdown(context),
              const SizedBox(height: 12),
              _buildSortOrderButton(context),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          initialDateRange: _dateRange,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030, 12, 31),
        );
        if (picked != null) {
          setState(() {
            _dateRange = picked;
          });
          widget.onDateRangeChanged?.call(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              _dateRange == null
                  ? AppStrings.tr(context, 'selectDateRange')
                  : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortByDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _sortField,
      decoration: InputDecoration(
        labelText: AppStrings.tr(context, 'sortBy'),
        border: const OutlineInputBorder(),
      ),
      items: widget.sortOptions
          .map((opt) => DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(AppStrings.tr(context, opt['label']!)),
              ))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _sortField = val;
          });
        }
      },
    );
  }

  Widget _buildSortOrderButton(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          tooltip: _sortAscending
              ? AppStrings.tr(context, 'ascending')
              : AppStrings.tr(context, 'descending'),
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
        ),
        Text(AppStrings.tr(context, 'sortOrder')),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.tr(context, 'cancel')),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_sortField, _sortAscending);
            Navigator.pop(context);
          },
          child: Text(AppStrings.tr(context, 'apply')),
        ),
      ],
    );
  }
}
