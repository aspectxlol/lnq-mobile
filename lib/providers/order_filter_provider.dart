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
    _orderStatus = status;
    _saveToStorage();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _saveToStorage();
    notifyListeners();
  }

  void setActiveDateFilter(String filter) {
    _activeDateFilter = filter;
    _saveToStorage();
    notifyListeners();
  }

  void setCreatedDateRange(DateTimeRange? range) {
    _createdDateRange = range;
    _saveToStorage();
    notifyListeners();
  }

  void setPickupDateRange(DateTimeRange? range) {
    _pickupDateRange = range;
    _saveToStorage();
    notifyListeners();
  }

  void setHidePastPickupDates(bool hide) {
    _hidePastPickupDates = hide;
    _saveToStorage();
    notifyListeners();
  }

  void setSortBy(OrderSortBy sort) {
    _sortBy = sort;
    _saveToStorage();
    notifyListeners();
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
  List<Order> filterOrders(List<Order> orders) {
    List<Order> filtered = orders;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.id.toString().contains(_searchQuery);
      }).toList();
    }

    // Filter by order status (new or scheduled)
    if (_orderStatus != OrderStatus.all) {
      filtered = filtered.where((order) {
        if (_orderStatus == OrderStatus.new_) {
          return order.pickupDate == null;
        } else if (_orderStatus == OrderStatus.scheduled) {
          return order.pickupDate != null;
        }
        return true;
      }).toList();
    }

    // Filter by created date range
    if (_activeDateFilter == 'createdDate' && _createdDateRange != null) {
      filtered = filtered.where((order) {
        final createdDate = order.createdAt;
        final rangeStart = _createdDateRange!.start;
        final rangeEnd = _createdDateRange!.end.add(Duration(days: 1));
        return createdDate.isAfter(rangeStart) && createdDate.isBefore(rangeEnd);
      }).toList();
    }

    // Filter by pickup date range
    if (_activeDateFilter == 'pickupDate' && _pickupDateRange != null) {
      filtered = filtered.where((order) {
        if (order.pickupDate == null) return false;
        final pickupDate = order.pickupDate!;
        final rangeStart = _pickupDateRange!.start;
        final rangeEnd = _pickupDateRange!.end.add(Duration(days: 1));
        return pickupDate.isAfter(rangeStart) && pickupDate.isBefore(rangeEnd);
      }).toList();
    }

    // Filter to hide past pickup dates
    if (_hidePastPickupDates) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      filtered = filtered.where((order) {
        if (order.pickupDate == null) return false;
        final pickupDate = order.pickupDate!;
        final pickupDay = DateTime(pickupDate.year, pickupDate.month, pickupDate.day);
        return pickupDay.isAtSameMomentAs(today) || pickupDay.isAfter(today);
      }).toList();
    }

    return filtered;
  }

  /// Sorts orders based on the selected sort option
  List<Order> sortOrders(List<Order> orders) {
    final sorted = List<Order>.from(orders);

    switch (_sortBy) {
      case OrderSortBy.createdDateDesc:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrderSortBy.createdDateAsc:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case OrderSortBy.pickupDateAsc:
        sorted.sort((a, b) {
          if (a.pickupDate == null && b.pickupDate == null) return 0;
          if (a.pickupDate == null) return 1;
          if (b.pickupDate == null) return -1;
          return a.pickupDate!.compareTo(b.pickupDate!);
        });
      case OrderSortBy.pickupDateDesc:
        sorted.sort((a, b) {
          if (a.pickupDate == null && b.pickupDate == null) return 0;
          if (a.pickupDate == null) return 1;
          if (b.pickupDate == null) return -1;
          return b.pickupDate!.compareTo(a.pickupDate!);
        });
      case OrderSortBy.totalAsc:
        sorted.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
      case OrderSortBy.totalDesc:
        sorted.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      case OrderSortBy.customerName:
        sorted.sort((a, b) => a.customerName.compareTo(b.customerName));
    }

    return sorted;
  }

  /// Applies both filtering and sorting to a list of orders
  List<Order> applyFiltersAndSort(List<Order> orders) {
    List<Order> result = filterOrders(orders);
    result = sortOrders(result);
    return result;
  }
}
