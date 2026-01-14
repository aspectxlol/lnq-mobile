/// Central location for all app constants
class AppConstants {
  // API Configuration
  static const String defaultBaseUrl = 'http://localhost:3000';
  static const String apiProductsEndpoint = '/api/products';
  static const String apiOrdersEndpoint = '/api/orders';
  static const String apiImagesEndpoint = '/api/images';
  static const String apiPrinterEndpoint = '/api/printer';
  static const String apiHealthEndpoint = '/health';
  static const int apiTimeoutSeconds = 30;
  static const int apiRetryAttempts = 3;
  static const Duration apiRetryDelay = Duration(milliseconds: 500);

  // Animation Durations
  static const Duration screenTransitionDuration = Duration(milliseconds: 300);
  static const Duration fabAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeTransitionDuration = Duration(milliseconds: 300);

  // Storage Keys
  static const String storageBaseUrlKey = 'base_url';
  static const String storageLocaleKey = 'locale';

  // Localization
  static const String defaultLocale = 'id';
  static const String defaultLocaleCountry = 'ID';
  static const String englishLocale = 'en';
  static const String englishLocaleCountry = 'US';

  // UI Constants
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultIconSize = 24.0;

  // Validation
  static const int maxProductNameLength = 100;
  static const int minProductPrice = 0;
  static const int maxProductPrice = 999999999;
  static const int minOrderAmount = 1;
  static const int maxOrderAmount = 9999;

  // Date Format
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';

  // HTTP Headers
  static const String contentTypeJson = 'application/json';

  AppConstants._();
}
