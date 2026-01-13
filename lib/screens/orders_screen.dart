import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../components/date_range_filter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_widgets.dart';
import '../components/order_card.dart';
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
                      Expanded(
                        child: DateRangeFilter(
                          activeFilter: _activeDateFilter,
                          createdDateRange: _createdDateRange,
                          pickupDateRange: _pickupDateRange,
                          onFilterChanged: (filter) {
                            setState(() {
                              _activeDateFilter = filter;
                            });
                          },
                          onCreatedDateChanged: (range) {
                            setState(() {
                              _createdDateRange = range;
                            });
                          },
                          onPickupDateChanged: (range) {
                            setState(() {
                              _pickupDateRange = range;
                            });
                          },
                        ),
                      ),
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
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonLoader();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox,
              title: 'No Orders',
              message: 'No orders found for the selected criteria.',
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
        ),
      ],
    );
  }
}

