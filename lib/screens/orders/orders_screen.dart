import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import '../../models/order.dart';
import '../../providers/settings_provider.dart';
import '../../providers/order_filter_provider.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/animated_widgets.dart';
import '../../components/order_card.dart';
import '../../theme/app_theme.dart';
import '../../l10n/strings.dart';
import '../../utils/data_loader_extension.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart';

enum OrderView { list, calendar }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _ordersFuture;
  OrderView _currentView = OrderView.list;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize with a pending future that will be resolved when settings are loaded
    _ordersFuture = _initializeAndLoadOrders();
    _selectedDay = _focusedDay;
  }

  Future<List<Order>> _initializeAndLoadOrders() async {
    final settings = context.read<SettingsProvider>();
    // Wait for settings to be initialized before loading orders
    await settings.ensureInitialized();
    return getApiService().getOrders();
  }

  void _loadOrders() {
    if (mounted) {
      setState(() {
        _ordersFuture = getApiService().getOrders();
      });
    }
  }

  void _onSearchChanged(OrderFiltersAndSorts filterProvider, String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        filterProvider.setSearchQuery(value);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    // Use select to only listen to specific filter properties to avoid unnecessary rebuilds
    final filterProvider = context.watch<OrderFiltersAndSorts>();
    final isLoaded = context.select<OrderFiltersAndSorts, bool>((provider) => provider.isLoaded);
    
    // Don't load orders until filters are loaded
    if (!isLoaded) {
      return const Scaffold(
        appBar: _LoadingAppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: const _OrdersAppBar(),
      body: Column(
        children: [
          // Search bar and action buttons
          _SearchAndActionBar(
            onSearchChanged: (value) => _onSearchChanged(filterProvider, value),
            onFilterPressed: () => _showFilterBottomSheet(context, filterProvider),
            onViewChanged: () => setState(() {
              _currentView = _currentView == OrderView.list
                  ? OrderView.calendar
                  : OrderView.list;
            }),
            currentView: _currentView,
          ),
          // Body content
          Expanded(
            child: FutureBuilder<List<Order>>(
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
                
                // Apply filters and sorting from the provider
                final allOrders = snapshot.data!;
                final filteredAndSortedOrders = filterProvider.applyFiltersAndSort(allOrders);
                
                if (filteredAndSortedOrders.isEmpty) {
                  return EmptyState(
                    icon: Icons.inbox,
                    title: AppStrings.trWatch(context, 'noOrders'),
                    message: AppStrings.trWatch(context, 'noOrdersFoundForCriteria'),
                  );
                }
                
                return _currentView == OrderView.list
                    ? _buildListView(filteredAndSortedOrders)
                    : _buildCalendarView(filteredAndSortedOrders);
              },
            ),
          ),
        ],
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
        tooltip: AppStrings.trWatch(context, 'createOrder'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, OrderFiltersAndSorts filterProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer<OrderFiltersAndSorts>(
          builder: (_, provider, _) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Modern bottom sheet header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Drag handle
                          Container(
                            width: 48,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.tune,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppStrings.trWatch(context, 'sortAndFilter'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sort By Section
                              _buildSectionHeader(context, 'sortBy', Icons.sort),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildSortChip(context, OrderSortBy.createdDateDesc, 'createdDateNewest', provider),
                                  _buildSortChip(context, OrderSortBy.createdDateAsc, 'createdDateOldest', provider),
                                  _buildSortChip(context, OrderSortBy.pickupDateAsc, 'pickupDateEarliest', provider),
                                  _buildSortChip(context, OrderSortBy.pickupDateDesc, 'pickupDateLatest', provider),
                                  _buildSortChip(context, OrderSortBy.totalAsc, 'totalAmountLowToHigh', provider),
                                  _buildSortChip(context, OrderSortBy.totalDesc, 'totalAmountHighToLow', provider),
                                  _buildSortChip(context, OrderSortBy.customerName, 'customerNameAZ', provider),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              // Order Status Filter
                              _buildSectionHeader(context, 'orderStatus', Icons.bookmark_outline),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildStatusChip(context, OrderStatus.all, 'all', provider),
                                  _buildStatusChip(context, OrderStatus.new_, 'new', provider),
                                  _buildStatusChip(context, OrderStatus.scheduled, 'scheduled', provider),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              // Date Range Filter Section
                              _buildSectionHeader(context, 'dateFilter', Icons.calendar_month),
                              const SizedBox(height: 12),
                              
                              // Active date filter toggle
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildDateFilterChip(context, 'createdDate', provider),
                                  _buildDateFilterChip(context, 'pickupDate', provider),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Date range picker
                              _buildDateRangePicker(context, provider),
                              const SizedBox(height: 32),
                              
                              // Hide past pickup dates checkbox
                              _buildCheckboxOption(
                                context,
                                AppStrings.trWatch(context, 'hidePastPickupDates'),
                                provider.hidePastPickupDates,
                                (val) => provider.setHidePastPickupDates(val ?? false),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom action buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: Text(AppStrings.trWatch(context, 'clearFilters')),
                              onPressed: () {
                                provider.resetAll();
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: Text(AppStrings.trWatch(context, 'apply')),
                              onPressed: () {
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          AppStrings.trWatch(context, label),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(BuildContext context, OrderSortBy sortType, String label, OrderFiltersAndSorts filterProvider) {
    final isSelected = filterProvider.sortBy == sortType;
    return FilterChip(
      label: Text(AppStrings.trWatch(context, label)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          filterProvider.setSortBy(sortType);
        }
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context, OrderStatus status, String label, OrderFiltersAndSorts filterProvider) {
    final isSelected = filterProvider.orderStatus == status;
    return FilterChip(
      label: Text(AppStrings.trWatch(context, label)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          filterProvider.setOrderStatus(status);
        }
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
  
  Widget _buildDateFilterChip(BuildContext context, String filterType, OrderFiltersAndSorts filterProvider) {
    final label = filterType == 'createdDate' ? 'createdDate' : 'pickupDate';
    final isSelected = filterProvider.activeDateFilter == filterType;
    return FilterChip(
      label: Text(AppStrings.trWatch(context, label)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          filterProvider.setActiveDateFilter(filterType);
        }
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, OrderFiltersAndSorts filterProvider) {
    return GestureDetector(
      onTap: () async {
        DateTimeRange? initial;
        if (filterProvider.activeDateFilter == 'createdDate') {
          initial = filterProvider.createdDateRange;
        } else {
          initial = filterProvider.pickupDateRange;
        }
        
        final picked = await showDateRangePicker(
          context: context,
          initialDateRange: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030, 12, 31),
        );
        
        if (picked != null) {
          if (filterProvider.activeDateFilter == 'createdDate') {
            filterProvider.setCreatedDateRange(picked);
          } else {
            filterProvider.setPickupDateRange(picked);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getDateRangeDisplay(filterProvider),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(BuildContext context, String label, bool value, Function(bool?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: value ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeDisplay(OrderFiltersAndSorts filterProvider) {
    DateTimeRange? range;
    if (filterProvider.activeDateFilter == 'createdDate') {
      range = filterProvider.createdDateRange;
    } else {
      range = filterProvider.pickupDateRange;
    }
    
    if (range == null) {
      return AppStrings.tr(context, 'selectDateRange');
    }
    return '${DateFormat('MMM d, yyyy').format(range.start)} - ${DateFormat('MMM d, yyyy').format(range.end)}';
  }

  Widget _buildListView(List<Order> orders) {
    // Orders are already filtered and sorted by the provider
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // extra bottom padding for FAB
      itemCount: orders.length,
      cacheExtent: 500, // Optimize viewport cache for smoother scrolling
      addRepaintBoundaries: true, // Keep true for individual item optimization
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          key: ValueKey(order.id),
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
        padding: const EdgeInsets.only(bottom: 100),
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
                      color: AppColors.primary.withValues(alpha: 0.3),
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
                        color: AppColors.primary.withValues(alpha: 0.1),
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
                    key: ValueKey(order.id),
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

// Extracted const widgets to avoid rebuilds
class _LoadingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LoadingAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppStrings.trWatch(context, 'orders')),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _OrdersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _OrdersAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppStrings.trWatch(context, 'orders')),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _SearchAndActionBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onViewChanged;
  final OrderView currentView;

  const _SearchAndActionBar({
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onViewChanged,
    required this.currentView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                prefixIconColor: AppColors.mutedForeground,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                currentView == OrderView.list
                    ? Icons.calendar_month
                    : Icons.view_list,
              ),
              onPressed: onViewChanged,
              tooltip: currentView == OrderView.list
                  ? AppStrings.trWatch(context, 'switchToCalendarView')
                  : AppStrings.trWatch(context, 'switchToListViewOrder'),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              tooltip: AppStrings.trWatch(context, 'sortAndFilter'),
              onPressed: onFilterPressed,
            ),
          ),
        ],
      ),
    );
  }
}
