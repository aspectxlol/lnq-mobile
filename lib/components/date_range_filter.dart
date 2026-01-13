
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatelessWidget {
  final String activeFilter;
  final DateTimeRange? createdDateRange;
  final DateTimeRange? pickupDateRange;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<DateTimeRange?> onCreatedDateChanged;
  final ValueChanged<DateTimeRange?> onPickupDateChanged;

  const DateRangeFilter({
    Key? key,
    required this.activeFilter,
    required this.createdDateRange,
    required this.pickupDateRange,
    required this.onFilterChanged,
    required this.onCreatedDateChanged,
    required this.onPickupDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ToggleButtons(
          isSelected: [
            activeFilter == 'createdDate',
            activeFilter == 'pickupDate',
          ],
          onPressed: (index) {
            onFilterChanged(index == 0 ? 'createdDate' : 'pickupDate');
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Created Date'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Pickup Date'),
            ),
          ],
        ),
        const SizedBox(width: 8),
        if (activeFilter == 'createdDate')
          DateRangePickerButton(
            dateRange: createdDateRange,
            onDateChanged: onCreatedDateChanged,
          ),
        if (activeFilter == 'pickupDate')
          DateRangePickerButton(
            dateRange: pickupDateRange,
            onDateChanged: onPickupDateChanged,
          ),
      ],
    );
  }
}

class DateRangePickerButton extends StatelessWidget {
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?> onDateChanged;

  const DateRangePickerButton({
    Key? key,
    required this.dateRange,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(
            dateRange == null
                ? 'All'
                : '${DateFormat('MMM d').format(dateRange!.start)} - ${DateFormat('MMM d').format(dateRange!.end)}',
          ),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 2),
              lastDate: DateTime(now.year + 2),
              initialDateRange: dateRange,
            );
            onDateChanged(picked);
          },
        ),
        if (dateRange != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => onDateChanged(null),
          ),
      ],
    );
  }
}
