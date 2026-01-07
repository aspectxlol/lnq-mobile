// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LNQ';

  @override
  String get products => 'Products';

  @override
  String get orders => 'Orders';

  @override
  String get settings => 'Settings';

  @override
  String get noProducts => 'No products available';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get createOrder => 'Create Order';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get productDetails => 'Product Details';

  @override
  String get price => 'Price';

  @override
  String get stock => 'Stock';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get total => 'Total';

  @override
  String get quantity => 'Quantity';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get version => 'Version';

  @override
  String get backendConfiguration => 'Backend Configuration';

  @override
  String get backendConfigurationDesc =>
      'Configure the backend server URL for the app.';

  @override
  String get backendUrl => 'Backend URL';

  @override
  String get backendUrlHint => 'http://localhost:3000';

  @override
  String get pleaseEnterBackendUrl => 'Please enter backend URL';

  @override
  String get urlMustStartWithHttp => 'URL must start with http:// or https://';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get testing => 'Testing...';

  @override
  String connectionSuccessful(Object db, Object minio) {
    return 'Connection successful!\nDB: $db, MinIO: $minio';
  }

  @override
  String connectionFailed(Object error) {
    return 'Connection failed: $error';
  }

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

  @override
  String failedToSaveSettings(Object error) {
    return 'Failed to save settings: $error';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetToDefaultTitle => 'Reset to Default';

  @override
  String get resetToDefaultConfirm =>
      'Are you sure you want to reset the backend URL to default?';

  @override
  String get reset => 'Reset';

  @override
  String get settingsResetToDefault => 'Settings reset to default';

  @override
  String failedToResetSettings(Object error) {
    return 'Failed to reset settings: $error';
  }

  @override
  String get indonesian => '🇮🇩 Bahasa Indonesia';

  @override
  String get english => '🇺🇸 English';

  @override
  String get about => 'About';

  @override
  String get appName => 'App Name';

  @override
  String get currentUrl => 'Current URL';
}
