import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';
import '../models/create_order_request.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return fromJson(data);
      } else {
        throw ApiException(
          data['message'] ?? 'Unknown error',
          response.statusCode,
        );
      }
    } else {
      final data = json.decode(response.body);
      throw ApiException(
        data['message'] ?? 'Request failed',
        response.statusCode,
      );
    }
  }

  // Products
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: _headers,
      );

      return await _handleResponse(
        response,
        (data) => (data['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList(),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch products: $e');
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: _headers,
      );

      return await _handleResponse(
        response,
        (data) => Product.fromJson(data['data']),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch product: $e');
    }
  }

  Future<Product> createProduct({
    required String name,
    required int price,
    String? description,
    String? imageId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'price': price,
          'description': description,
          'imageId': imageId,
        }),
      );

      return await _handleResponse(
        response,
        (data) => Product.fromJson(data['data']),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create product: $e');
    }
  }

  Future<Product> updateProduct(
    int id, {
    String? name,
    int? price,
    String? description,
    String? imageId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (price != null) body['price'] = price;
      if (description != null) body['description'] = description;
      if (imageId != null) body['imageId'] = imageId;

      final response = await http.put(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: _headers,
        body: json.encode(body),
      );

      return await _handleResponse(
        response,
        (data) => Product.fromJson(data['data']),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: _headers,
      );

      await _handleResponse(response, (data) => null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete product: $e');
    }
  }

  // Orders
  Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: _headers,
      );

      return await _handleResponse(
        response,
        (data) =>
            (data['data'] as List).map((item) => Order.fromJson(item)).toList(),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch orders: $e');
    }
  }

  Future<Order> getOrder(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$id'),
        headers: _headers,
      );

      return await _handleResponse(
        response,
        (data) => Order.fromJson(data['data']),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch order: $e');
    }
  }

  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(
        response,
        (data) => Order.fromJson(data['data']),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create order: $e');
    }
  }

  Future<Order> updateOrder(
    int id, {
    String? customerName,
    DateTime? pickupDate,
    String? notes,
    List<CreateOrderItem>? items,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (customerName != null && customerName.isNotEmpty) {
        body['customerName'] = customerName;
      }
      
      if (pickupDate != null) {
        body['pickupDate'] =
            '${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}';
      }
      
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      // If items is provided, it will replace all existing items
      if (items != null && items.isNotEmpty) {
        body['items'] = items.map((item) => item.toJson()).toList();
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$id'),
        headers: _headers,
        body: json.encode(body),
      );

      return await _handleResponse(
        response,
        (data) => Order.fromJson(data['data']),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update order: $e');
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/orders/$id'),
        headers: _headers,
      );

      await _handleResponse(response, (data) => null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete order: $e');
    }
  }

  Future<Map<String, dynamic>> printOrder(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/printer/orders/$id/print'),
        headers: _headers,
      );

      return await _handleResponse(
        response,
        (data) => data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to print order: $e');
    }
  }

  // Health check
  Future<Map<String, String>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Map<String, String>.from(json.decode(response.body));
      } else {
        throw ApiException('Health check failed', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Health check failed: $e');
    }
  }
}
