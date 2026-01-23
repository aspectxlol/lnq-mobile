import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

enum OrderStatus { all, new_, scheduled }

enum OrderSortBy {
  createdDateDesc,
  createdDateAsc,
  pickupDateAsc,
  pickupDateDesc,
  totalAsc,
  totalDesc,
  customerName,
}

class OrderFiltersAndSorts extends ChangeNotifier {
  OrderStatus _orderStatus = OrderStatus.all;
  String _searchQuery = '';
  String _activeDateFilter = 'createdDate';
  DateTimeRange? _createdDateRange;
  DateTimeRange? _pickupDateRange;
  bool _hidePastPickupDates = false;
  OrderSortBy _sortBy = OrderSortBy.createdDateDesc;
  bool _isLoaded = false;
  
  // Cache for filter results to avoid recalculation
  List<Order>? _cachedOrders;
  List<Order>? _cachedFilteredOrders;
  int _cacheHashCode = 0;

  // Getters
  OrderStatus get orderStatus => _orderStatus;
  String get searchQuery => _searchQuery;
  String get activeDateFilter => _activeDateFilter;
  DateTimeRange? get createdDateRange => _createdDateRange;
  DateTimeRange? get pickupDateRange => _pickupDateRange;
  bool get hidePastPickupDates => _hidePastPickupDates;
  OrderSortBy get sortBy => _sortBy;
  bool get isLoaded => _isLoaded;

  OrderFiltersAndSorts() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _orderStatus = OrderStatus.values[prefs.getInt('orderStatus') ?? 0];
      _searchQuery = prefs.getString('searchQuery') ?? '';
      _activeDateFilter = prefs.getString('activeDateFilter') ?? 'createdDate';
      _hidePastPickupDates = prefs.getBool('hidePastPickupDates') ?? false;
      _sortBy = OrderSortBy.values[prefs.getInt('sortBy') ?? 0];
      
      // Load date ranges from storage
      final createdStart = prefs.getString('createdDateRangeStart');
      final createdEnd = prefs.getString('createdDateRangeEnd');
      if (createdStart != null && createdEnd != null) {
        _createdDateRange = DateTimeRange(
          start: DateTime.parse(createdStart),
          end: DateTime.parse(createdEnd),
        );
      }

      final pickupStart = prefs.getString('pickupDateRangeStart');
      final pickupEnd = prefs.getString('pickupDateRangeEnd');
      if (pickupStart != null && pickupEnd != null) {
        _pickupDateRange = DateTimeRange(
          start: DateTime.parse(pickupStart),
          end: DateTime.parse(pickupEnd),
        );
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('orderStatus', _orderStatus.index);
      await prefs.setString('searchQuery', _searchQuery);
      await prefs.setString('activeDateFilter', _activeDateFilter);
      await prefs.setBool('hidePastPickupDates', _hidePastPickupDates);
      await prefs.setInt('sortBy', _sortBy.index);

      // Save date ranges
      if (_createdDateRange != null) {
        await prefs.setString('createdDateRangeStart', _createdDateRange!.start.toIso8601String());
        await prefs.setString('createdDateRangeEnd', _createdDateRange!.end.toIso8601String());
      } else {
        await prefs.remove('createdDateRangeStart');
        await prefs.remove('createdDateRangeEnd');
      }

      if (_pickupDateRange != null) {
        await prefs.setString('pickupDateRangeStart', _pickupDateRange!.start.toIso8601String());
        await prefs.setString('pickupDateRangeEnd', _pickupDateRange!.end.toIso8601String());
      } else {
        await prefs.remove('pickupDateRangeStart');
        await prefs.remove('pickupDateRangeEnd');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void setOrderStatus(OrderStatus status) {
    if (_orderStatus != status) {
      _orderStatus = status;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setActiveDateFilter(String filter) {
    if (_activeDateFilter != filter) {
      _activeDateFilter = filter;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setCreatedDateRange(DateTimeRange? range) {
    if (_createdDateRange != range) {
      _createdDateRange = range;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setPickupDateRange(DateTimeRange? range) {
    if (_pickupDateRange != range) {
      _pickupDateRange = range;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setHidePastPickupDates(bool hide) {
    if (_hidePastPickupDates != hide) {
      _hidePastPickupDates = hide;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  void setSortBy(OrderSortBy sort) {
    if (_sortBy != sort) {
      _sortBy = sort;
      _invalidateCache();
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Invalidates the cached filter results
  void _invalidateCache() {
    _cachedFilteredOrders = null;
    _cacheHashCode = 0;
  }

  void resetAll() {
    _orderStatus = OrderStatus.all;
    _searchQuery = '';
    _activeDateFilter = 'createdDate';
    _createdDateRange = null;
    _pickupDateRange = null;
    _hidePastPickupDates = false;
    _sortBy = OrderSortBy.createdDateDesc;
    _saveToStorage();
    notifyListeners();
  }

  /// Filters orders based on all active filters
  /// Uses early return for efficiency
  List<Order> filterOrders(List<Order> orders) {
    if (orders.isEmpty) return orders;
    
    // Create a filtered list with early returns for efficiency
    return orders.where((order) {
      // Filter by search query (fastest check first due to string operations)
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.id.toString().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      // Filter by order status
      if (_orderStatus != OrderStatus.all) {
        final hasPickupDate = order.pickupDate != null;
        final isNew = !hasPickupDate;
        final isScheduled = hasPickupDate;
        
        final statusMatches = (_orderStatus == OrderStatus.new_ && isNew) ||
            (_orderStatus == OrderStatus.scheduled && isScheduled);
        if (!statusMatches) return false;
      }

      // Filter by created date range (only if set)
      if (_activeDateFilter == 'createdDate' && _createdDateRange != null) {
        final createdDate = order.createdAt;
        final rangeStart = _createdDateRange!.start;
        final rangeEnd = _createdDateRange!.end.add(const Duration(days: 1));
        if (createdDate.isBefore(rangeStart) || createdDate.isAfter(rangeEnd)) return false;
      }

      // Filter by pickup date range (only if set)
      if (_activeDateFilter == 'pickupDate' && _pickupDateRange != null) {
        if (order.pickupDate == null) return false;
        final pickupDate = order.pickupDate!;
        final rangeStart = _pickupDateRange!.start;
        final rangeEnd = _pickupDateRange!.end.add(const Duration(days: 1));
        if (pickupDate.isBefore(rangeStart) || pickupDate.isAfter(rangeEnd)) return false;
      }

      // Filter to hide past pickup dates
      if (_hidePastPickupDates) {
        if (order.pickupDate == null) return false;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final pickupDay = DateTime(order.pickupDate!.year, order.pickupDate!.month, order.pickupDate!.day);
        if (pickupDay.isBefore(today)) return false;
      }

      return true;
    }).toList();
  }

  /// Sorts orders based on the selected sort option
  /// Modifies list in-place to avoid allocations
  List<Order> sortOrders(List<Order> orders) {
    if (orders.isEmpty || orders.length == 1) return orders;
    
    switch (_sortBy) {
      case OrderSortBy.createdDateDesc:
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrderSortBy.createdDateAsc:
        orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case OrderSortBy.pickupDateAsc:
        orders.sort((a, b) {
          if (a.pickupDate == null && b.pickupDate == null) return 0;
          if (a.pickupDate == null) return 1;
          if (b.pickupDate == null) return -1;
          return a.pickupDate!.compareTo(b.pickupDate!);
        });
      case OrderSortBy.pickupDateDesc:
        orders.sort((a, b) {
          if (a.pickupDate == null && b.pickupDate == null) return 0;
          if (a.pickupDate == null) return 1;
          if (b.pickupDate == null) return -1;
          return b.pickupDate!.compareTo(a.pickupDate!);
        });
      case OrderSortBy.totalAsc:
        orders.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
      case OrderSortBy.totalDesc:
        orders.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      case OrderSortBy.customerName:
        orders.sort((a, b) => a.customerName.compareTo(b.customerName));
    }

    return orders;
  }

  /// Applies both filtering and sorting to a list of orders
  /// Uses caching to avoid recalculation when data hasn't changed
  List<Order> applyFiltersAndSort(List<Order> orders) {
    // Check if we have cached results for the same input
    final currentHashCode = orders.hashCode;
    if (_cachedOrders == orders && _cachedFilteredOrders != null && _cacheHashCode == currentHashCode) {
      return _cachedFilteredOrders!;
    }
    
    // Cache miss: apply filters and sorting
    List<Order> result = filterOrders(orders);
    result = sortOrders(result);
    
    // Update cache
    _cachedOrders = orders;
    _cachedFilteredOrders = result;
    _cacheHashCode = currentHashCode;
    
    return result;
  }
}
