import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart' hide Theme;

enum OrderView { list, calendar }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _sortByPickupDate = false;
  late Future<List<Order>> _ordersFuture;
  OrderView _currentView = OrderView.list;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _searchQuery = '';
  DateTimeRange? _pickupDateRange;
  DateTimeRange? _createdDateRange;
  String _activeDateFilter = 'createdDate'; // 'createdDate' or 'pickupDate'

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _selectedDay = _focusedDay;
    // Default: createdDate Jan 1 - Jan 31
    final now = DateTime.now();
    final janFirst = DateTime(now.year, 1, 1);
    final janLast = DateTime(now.year, 1, 31);
    _createdDateRange = DateTimeRange(start: janFirst, end: janLast);
  }

  void _loadOrders() {
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    final apiService = ApiService(baseUrl);
    setState(() {
      _ordersFuture = apiService.getOrders();
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
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by customer or order ID',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ToggleButtons(
                        isSelected: [
                          _activeDateFilter == 'createdDate',
                          _activeDateFilter == 'pickupDate',
                        ],
                        onPressed: (index) {
                          setState(() {
                            _activeDateFilter = index == 0
                                ? 'createdDate'
                                : 'pickupDate';
                          });
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
                      if (_activeDateFilter == 'createdDate')
                        TextButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _createdDateRange == null
                                ? 'All'
                                : '${DateFormat('MMM d').format(_createdDateRange!.start)} - ${DateFormat('MMM d').format(_createdDateRange!.end)}',
                          ),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(now.year - 2),
                              lastDate: DateTime(now.year + 2),
                              initialDateRange: _createdDateRange,
                            );
                            if (picked != null) {
                              setState(() {
                                _createdDateRange = picked;
                              });
                            }
                          },
                        ),
                      if (_activeDateFilter == 'createdDate' &&
                          _createdDateRange != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _createdDateRange = null;
                            });
                          },
                        ),
                      if (_activeDateFilter == 'pickupDate')
                        TextButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _pickupDateRange == null
                                ? 'All'
                                : '${DateFormat('MMM d').format(_pickupDateRange!.start)} - ${DateFormat('MMM d').format(_pickupDateRange!.end)}',
                          ),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(now.year - 2),
                              lastDate: DateTime(now.year + 2),
                              initialDateRange: _pickupDateRange,
                            );
                            if (picked != null) {
                              setState(() {
                                _pickupDateRange = picked;
                              });
                            }
                          },
                        ),
                      if (_activeDateFilter == 'pickupDate' &&
                          _pickupDateRange != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _pickupDateRange = null;
                            });
                          },
                        ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _sortByPickupDate,
                            onChanged: (val) {
                              setState(() {
                                _sortByPickupDate = val ?? false;
                              });
                            },
                          ),
                          const Text('Sort by Pickup Date (hide past)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          );
          if (result == true) {
            _loadOrders();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.trWatch(context, 'newOrder')),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListSkeleton(
              itemCount: 5,
              itemBuilder: (context, index) => const OrderCardSkeleton(),
            );
          }

          if (snapshot.hasError) {
            String errorMsg = 'Failed to load orders';
            final error = snapshot.error;
            if (error is ApiException) {
              errorMsg = error.message;
            } else if (error is Exception) {
              errorMsg = error.toString();
            }
            return ErrorState(
              message: errorMsg,
              onRetry: _loadOrders,
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.trWatch(context, 'noOrders'),
              message: AppStrings.trWatch(context, 'createFirstOrder'),
              action: ElevatedButton.icon(
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
                icon: const Icon(Icons.add),
                label: Text(AppStrings.trWatch(context, 'createOrder')),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadOrders();
              await _ordersFuture;
            },
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            child: _currentView == OrderView.list
                ? _buildListView(orders)
                : _buildCalendarView(orders),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Order> orders) {
    // Filter orders by search and date filter
    List<Order> filtered = orders.where((order) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          order.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          order.id.toString().contains(_searchQuery);
      bool matchesDate = true;
      if (_activeDateFilter == 'createdDate') {
        matchesDate =
            _createdDateRange == null ||
            (order.createdAt.isAfter(
                  _createdDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                order.createdAt.isBefore(
                  _createdDateRange!.end.add(const Duration(days: 1)),
                ));
      } else if (_activeDateFilter == 'pickupDate') {
        matchesDate =
            _pickupDateRange == null ||
            (order.pickupDate != null &&
                order.pickupDate!.isAfter(
                  _pickupDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                order.pickupDate!.isBefore(
                  _pickupDateRange!.end.add(const Duration(days: 1)),
                ));
      }
      bool notPast = true;
      if (_sortByPickupDate) {
        // Only show orders with pickupDate today or in the future
        final now = DateTime.now();
        notPast =
            order.pickupDate != null &&
            !order.pickupDate!.isBefore(DateTime(now.year, now.month, now.day));
      }
      return matchesSearch && matchesDate && (!_sortByPickupDate || notPast);
    }).toList();
    if (_sortByPickupDate) {
      filtered.sort((a, b) {
        if (a.pickupDate == null && b.pickupDate == null) return 0;
        if (a.pickupDate == null) return 1;
        if (b.pickupDate == null) return -1;
        return a.pickupDate!.compareTo(b.pickupDate!);
      });
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        return _OrderCard(
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

    return Column(
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
        Expanded(
          child: selectedOrders.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy,
                  title: AppStrings.trWatch(context, 'noOrders'),
                  message: _selectedDay != null
                      ? AppStrings.trWatch(context, 'noOrdersScheduled')
                      : AppStrings.trWatch(context, 'selectDateToView'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedOrders.length,
                  itemBuilder: (context, index) {
                    final order = selectedOrders[index];
                    return _OrderCard(
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
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.customerName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: order.pickupDate != null
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: order.pickupDate != null
                        ? AppColors.success
                        : AppColors.secondary,
                  ),
                ),
                child: Text(
                  order.pickupDate != null
                      ? AppStrings.trWatch(context, 'scheduled')
                      : AppStrings.trWatch(context, 'new'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: order.pickupDate != null
                        ? AppColors.success
                        : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.receipt, size: 16, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text(
                'Order #${order.id}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          if (order.pickupDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  '${AppStrings.trWatch(context, 'pickup')}: ${_formatDate(order.pickupDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.itemCount} ${AppStrings.trWatch(context, 'items')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(
                order.formattedTotal,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }
}
