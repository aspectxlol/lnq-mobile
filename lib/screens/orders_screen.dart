import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_widgets.dart';
import '../components/order_card.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import '../utils/data_loader_extension.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart';

enum OrderView { list, calendar }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

// Modal dialog for sort and filter controls
class _SortFilterDialog extends StatefulWidget {
  final String sortField;
  final bool sortAscending;
  final DateTimeRange? pickupDateRange;
  final bool hidePast;
  final List<Map<String, String>> sortOptions;
  final void Function(String, bool, DateTimeRange?, bool) onApply;

  const _SortFilterDialog({
    required this.sortField,
    required this.sortAscending,
    required this.pickupDateRange,
    required this.hidePast,
    required this.sortOptions,
    required this.onApply,
  });

  @override
  State<_SortFilterDialog> createState() => _SortFilterDialogState();
}

class _SortFilterDialogState extends State<_SortFilterDialog> {
  late String _sortField;
  late bool _sortAscending;
  DateTimeRange? _pickupDateRange;
  late bool _hidePast;

  @override
  void initState() {
    super.initState();
    _sortField = widget.sortField;
    _sortAscending = widget.sortAscending;
    _pickupDateRange = widget.pickupDateRange;
    _hidePast = widget.hidePast;
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
              Text(AppStrings.trWatch(context, 'sortAndFilter'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: _pickupDateRange,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030, 12, 31),
                  );
                  if (picked != null) {
                    setState(() {
                      _pickupDateRange = picked;
                    });
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
                        _pickupDateRange == null
                            ? AppStrings.trWatch(context, 'pickupDateRange')
                            : '${DateFormat('MMM d, yyyy').format(_pickupDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_pickupDateRange!.end)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _sortField,
                decoration: InputDecoration(
                  labelText: AppStrings.trWatch(context, 'sortBy'),
                  border: const OutlineInputBorder(),
                ),
                items: widget.sortOptions
                    .map((opt) => DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(AppStrings.trWatch(context, opt['label']!)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _sortField = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                    tooltip: _sortAscending ? AppStrings.trWatch(context, 'ascending') : AppStrings.trWatch(context, 'descending'),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                  ),
                  Text(AppStrings.trWatch(context, 'sortOrder')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _hidePast,
                    onChanged: (val) {
                      setState(() {
                        _hidePast = val ?? false;
                      });
                    },
                  ),
                  Text(AppStrings.trWatch(context, 'hidePast')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: Text(AppStrings.trWatch(context, 'clearFilters')),
                    onPressed: () {
                      setState(() {
                        _pickupDateRange = null;
                        _hidePast = false;
                        _sortField = 'pickupDate';
                        _sortAscending = true;
                      });
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_sortField, _sortAscending, _pickupDateRange, _hidePast);
                      Navigator.of(context).pop();
                    },
                    child: Text(AppStrings.trWatch(context, 'apply')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _sortField = 'pickupDate';
  bool _sortAscending = true;
  bool _hidePast = false;
  late Future<List<Order>> _ordersFuture;
  OrderView _currentView = OrderView.list;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _searchQuery = '';
  DateTimeRange? _pickupDateRange;
  final List<Map<String, String>> _sortOptions = [
    {'value': 'pickupDate', 'label': 'pickupDate'},
    {'value': 'createdAt', 'label': 'created'},
    {'value': 'customerName', 'label': 'customerName'},
    {'value': 'id', 'label': 'orderId'},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _selectedDay = _focusedDay;
    // Default: pickupDate is this month
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    _pickupDateRange = DateTimeRange(start: monthStart, end: monthEnd);
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = getApiService().getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.trWatch(context, 'orders')),
        actions: [
          IconButton(
            icon: Icon(
              _currentView == OrderView.list
                  ? Icons.calendar_month
                  : Icons.view_list,
            ),
            onPressed: () {
              setState(() {
                _currentView = _currentView == OrderView.list
                    ? OrderView.calendar
                    : OrderView.list;
              });
            },
            tooltip: _currentView == OrderView.list
                ? AppStrings.trWatch(context, 'switchToCalendarView')
                : AppStrings.trWatch(context, 'switchToListViewOrder'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppStrings.trWatch(context, 'searchByCustomerOrOrderId'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.tune),
                  tooltip: AppStrings.trWatch(context, 'sortAndFilter'),
                  iconSize: 28,
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => _SortFilterDialog(
                        sortField: _sortField,
                        sortAscending: _sortAscending,
                        pickupDateRange: _pickupDateRange,
                        hidePast: _hidePast,
                        sortOptions: _sortOptions,
                        onApply: (String sortField, bool sortAscending, DateTimeRange? pickupDateRange, bool hidePast) {
                          setState(() {
                            _sortField = sortField;
                            _sortAscending = sortAscending;
                            _pickupDateRange = pickupDateRange;
                            _hidePast = hidePast;
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // End of AppBar actions and filters
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonLoader();
          } else if (snapshot.hasError) {
            return Center(child: Text(AppStrings.trWatch(context, 'error')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyState(
              icon: Icons.inbox,
              title: AppStrings.trWatch(context, 'noOrders'),
              message: AppStrings.trWatch(context, 'noOrdersFoundForCriteria'),
            );
          }
          final orders = snapshot.data!;
          return _currentView == OrderView.list
              ? _buildListView(orders)
              : _buildCalendarView(orders);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOrderScreen(),
            ),
          );
          if (result == true) {
            _loadOrders();
          }
        },
        child: const Icon(Icons.add),
        tooltip: AppStrings.trWatch(context, 'createOrder'),
      ),
    );
  }

  Widget _buildListView(List<Order> orders) {
    // Filter orders by search and pickup date only
    List<Order> filtered = orders.where((order) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          order.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          order.id.toString().contains(_searchQuery);
      bool matchesPickupDate = _pickupDateRange == null ||
          (order.pickupDate != null &&
              order.pickupDate!.isAfter(
                _pickupDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              order.pickupDate!.isBefore(
                _pickupDateRange!.end.add(const Duration(days: 1)),
              ));
      bool notPast = true;
      if (_hidePast) {
        final now = DateTime.now();
        notPast = order.pickupDate != null &&
            !order.pickupDate!.isBefore(DateTime(now.year, now.month, now.day));
      }
      return matchesSearch && matchesPickupDate && (!_hidePast || notPast);
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      int cmp = 0;
      switch (_sortField) {
        case 'pickupDate':
          if (a.pickupDate == null && b.pickupDate == null) cmp = 0;
          else if (a.pickupDate == null) cmp = 1;
          else if (b.pickupDate == null) cmp = -1;
          else cmp = a.pickupDate!.compareTo(b.pickupDate!);
          break;
        case 'createdAt':
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case 'customerName':
          cmp = a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
          break;
        case 'id':
          cmp = a.id.toString().compareTo(b.id.toString());
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // extra bottom padding for FAB
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        return OrderCard(
          order: order,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(orderId: order.id),
              ),
            );
            if (result == true) {
              _loadOrders();
            }
          },
        );
      },
    );
  }

  Widget _buildCalendarView(List<Order> orders) {
    final ordersWithPickup = orders.where((o) => o.pickupDate != null).toList();

    // Group orders by pickup date
    Map<DateTime, List<Order>> ordersByDate = {};
    for (var order in ordersWithPickup) {
      final date = DateTime(
        order.pickupDate!.year,
        order.pickupDate!.month,
        order.pickupDate!.day,
      );
      if (ordersByDate[date] == null) {
        ordersByDate[date] = [];
      }
      ordersByDate[date]!.add(order);
    }

    // Get orders for selected day
    final selectedOrders = _selectedDay != null
        ? (ordersByDate[DateTime(
                _selectedDay!.year,
                _selectedDay!.month,
                _selectedDay!.day,
              )] ??
              [])
        : <Order>[];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedCard(
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: Theme.of(context).textTheme.titleLarge!,
                  ),
                  eventLoader: (day) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    return ordersByDate[normalizedDay] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.event, size: 20, color: AppColors.mutedForeground),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDay != null
                        ? DateFormat('MMMM dd, yyyy').format(_selectedDay!)
                        : AppStrings.trWatch(context, 'selectADate'),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (selectedOrders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedOrders.length} ${selectedOrders.length == 1 ? AppStrings.trWatch(context, 'order') : AppStrings.trWatch(context, 'ordersPlural')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (selectedOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EmptyState(
                  icon: Icons.event_busy,
                  title: AppStrings.trWatch(context, 'noOrders'),
                  message: _selectedDay != null
                      ? AppStrings.trWatch(context, 'noOrdersScheduled')
                      : AppStrings.trWatch(context, 'selectDateToView'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96), // extra bottom padding for FAB
                itemCount: selectedOrders.length,
                itemBuilder: (context, index) {
                  final order = selectedOrders[index];
                  return OrderCard(
                    order: order,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(orderId: order.id),
                        ),
                      );
                      if (result == true) {
                        _loadOrders();
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

