import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

/// Service for discovering and connecting to local backend servers
class BackendDiscoveryService {
  static const int _discoveryPort = 3000;
  static const Duration _discoveryTimeout = Duration(seconds: 2);
  static const int _maxParallelRequests = 10;

  /// Discover backend servers on the local network
  /// Scans common IP ranges and checks healthcheck endpoint
  /// Returns the first working backend URL or null
  static Future<String?> discoverBackend() async {
    try {
      // Get local IP address
      final localIp = await _getLocalIpAddress();
      if (localIp == null) {
        return null;
      }

      // Extract network prefix (e.g., 192.168.1 from 192.168.1.100)
      final parts = localIp.split('.');
      if (parts.length != 4) {
        return null;
      }

      final networkPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';

      // Scan IP range for backend servers
      final candidates = <String>[];
      for (int i = 1; i <= 254; i++) {
        candidates.add('$networkPrefix.$i');
      }

      // Check candidates in parallel with controlled concurrency
      final results = <String?>[];
      for (int i = 0; i < candidates.length; i += _maxParallelRequests) {
        final batch = candidates.skip(i).take(_maxParallelRequests).toList();
        final batchResults = await Future.wait(
          batch.map((ip) => _checkBackendAtIp(ip)).toList(),
          eagerError: false,
        );
        results.addAll(batchResults);

        // If we found a backend, return immediately
        final found = results.firstWhere((url) => url != null, orElse: () => null);
        if (found != null) {
          return found;
        }
      }

      // Also check localhost as fallback
      final localhostUrl = await _checkBackendAtIp('127.0.0.1');
      if (localhostUrl != null) {
        return localhostUrl;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the local IP address of the device
  static Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          // Only consider IPv4 addresses
          if (address.type == InternetAddressType.IPv4) {
            // Skip loopback addresses
            if (!address.address.startsWith('127.0')) {
              return address.address;
            }
          }
        }
      }
      // Fallback to localhost if no other address found
      return '127.0.0.1';
    } catch (e) {
      return null;
    }
  }

  /// Check if a backend server is running at the given IP
  static Future<String?> _checkBackendAtIp(String ip) async {
    try {
      final url = 'http://$ip:$_discoveryPort${AppConstants.apiHealthEndpoint}';
      final response = await http
          .get(Uri.parse(url))
          .timeout(_discoveryTimeout);

      if (response.statusCode == 200) {
        // Verify it's a valid backend response
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          // Check if it has expected health check fields
          if (data.containsKey('db') || data.containsKey('status')) {
            return 'http://$ip:$_discoveryPort';
          }
        } catch (e) {
          // Not a valid JSON response, skip
        }
      }
    } catch (e) {
      // Connection failed, this IP doesn't have a backend
    }
    return null;
  }

  /// Verify that a backend URL is still accessible
  static Future<bool> verifyBackend(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${AppConstants.apiHealthEndpoint}'))
          .timeout(_discoveryTimeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
