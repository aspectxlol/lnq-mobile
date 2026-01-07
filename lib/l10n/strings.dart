import 'package:flutter/material.dart';

class AppStrings {
  static final Map<String, Map<String, String>> _strings = {
    'en': {
      // App
      'products': 'Products',
      'orders': 'Orders',
      'settings': 'Settings',

      // Products Screen
      'switchToListView': 'Switch to List View',
      'switchToCardView': 'Switch to Card View',
      'noProducts': 'No Products',
      'noProductsAvailable': 'No products available at the moment.',

      // Orders Screen
      'newOrder': 'New Order',
      'switchToCalendarView': 'Switch to Calendar View',
      'switchToListViewOrder': 'Switch to List View',
      'noOrders': 'No Orders',
      'noOrdersAvailable': 'No orders available at the moment.',

      // Create/Edit Order
      'createOrder': 'Create Order',
      'customerName': 'Customer Name',
      'selectPickupDate': 'Select Pickup Date',
      'pickupDate': 'Pickup Date',
      'selectProducts': 'Select Products',
      'quantity': 'Quantity',
      'pleaseSelectAtLeastOneProduct': 'Please select at least one product',
      'createOrderError': 'Error creating order',
      'orderCreatedSuccessfully': 'Order created successfully',
      'orderCreationFailed': 'Failed to create order',

      // Product Details
      'productDetails': 'Product Details',
      'price': 'Price',
      'stock': 'Stock',
      'description': 'Description',
      'loadingProductFailed': 'Failed to load product',

      // Order Details
      'orderDetails': 'Order Details',
      'status': 'Status',
      'totalAmount': 'Total Amount',
      'printOrder': 'Print Order',
      'loadingOrderFailed': 'Failed to load order',
      'orderPrintedSuccessfully': 'Order printed successfully',
      'orderPrintFailed': 'Failed to print order',

      // Backend Configuration
      'backendConfiguration': 'Backend Configuration',
      'backendConfigurationDesc':
          'Configure the backend server URL for the app.',
      'serverUrl': 'Server URL',
      'backendUrl': 'Backend URL',
      'backendUrlHint': 'http://localhost:3000',
      'pleaseEnterBackendUrl': 'Please enter backend URL',
      'urlMustStartWithHttp': 'URL must start with http:// or https://',
      'testConnection': 'Test Connection',
      'testing': 'Testing...',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'confirm': 'Confirm',
      'reset': 'Reset',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',

      // Messages
      'connectionSuccessful': 'Connection successful!',
      'connectionFailed': 'Connection failed',
      'settingsSavedSuccessfully': 'Settings saved successfully',
      'failedToSaveSettings': 'Failed to save settings',
      'settingsResetToDefault': 'Settings reset to default',
      'failedToResetSettings': 'Failed to reset settings',

      // Quick Actions & Settings
      'quickActions': 'Quick Actions',
      'resetToDefault': 'Reset to Default',
      'resetToDefaultTitle': 'Reset to Default',
      'resetToDefaultConfirm':
          'Are you sure you want to reset the backend URL to default?',
      'language': 'Language',
      'indonesian': '🇮🇩 Bahasa Indonesia',
      'english': '🇺🇸 English',
      'about': 'About',
      'appName': 'App Name',
      'version': 'Version',
      'currentUrl': 'Current URL',
    },
    'id': {
      // App
      'products': 'Produk',
      'orders': 'Pesanan',
      'settings': 'Pengaturan',

      // Products Screen
      'switchToListView': 'Beralih ke Tampilan Daftar',
      'switchToCardView': 'Beralih ke Tampilan Kartu',
      'noProducts': 'Tidak Ada Produk',
      'noProductsAvailable': 'Tidak ada produk tersedia saat ini.',

      // Orders Screen
      'newOrder': 'Pesanan Baru',
      'switchToCalendarView': 'Beralih ke Tampilan Kalender',
      'switchToListViewOrder': 'Beralih ke Tampilan Daftar',
      'noOrders': 'Tidak Ada Pesanan',
      'noOrdersAvailable': 'Tidak ada pesanan tersedia saat ini.',

      // Create/Edit Order
      'createOrder': 'Buat Pesanan',
      'customerName': 'Nama Pelanggan',
      'selectPickupDate': 'Pilih Tanggal Pengambilan',
      'pickupDate': 'Tanggal Pengambilan',
      'selectProducts': 'Pilih Produk',
      'quantity': 'Jumlah',
      'pleaseSelectAtLeastOneProduct': 'Mohon pilih setidaknya satu produk',
      'createOrderError': 'Kesalahan membuat pesanan',
      'orderCreatedSuccessfully': 'Pesanan berhasil dibuat',
      'orderCreationFailed': 'Gagal membuat pesanan',

      // Product Details
      'productDetails': 'Detail Produk',
      'price': 'Harga',
      'stock': 'Stok',
      'description': 'Deskripsi',
      'loadingProductFailed': 'Gagal memuat produk',

      // Order Details
      'orderDetails': 'Detail Pesanan',
      'status': 'Status',
      'totalAmount': 'Jumlah Total',
      'printOrder': 'Cetak Pesanan',
      'loadingOrderFailed': 'Gagal memuat pesanan',
      'orderPrintedSuccessfully': 'Pesanan berhasil dicetak',
      'orderPrintFailed': 'Gagal mencetak pesanan',

      // Backend Configuration
      'backendConfiguration': 'Konfigurasi Backend',
      'backendConfigurationDesc': 'Atur URL server backend untuk aplikasi.',
      'serverUrl': 'URL Server',
      'backendUrl': 'URL Backend',
      'backendUrlHint': 'http://localhost:3000',
      'pleaseEnterBackendUrl': 'Mohon masukkan URL backend',
      'urlMustStartWithHttp': 'URL harus dimulai dengan http:// atau https://',
      'testConnection': 'Tes Koneksi',
      'testing': 'Menguji...',

      // Common
      'save': 'Simpan',
      'cancel': 'Batal',
      'delete': 'Hapus',
      'edit': 'Edit',
      'add': 'Tambah',
      'confirm': 'Konfirmasi',
      'reset': 'Kembalikan',
      'loading': 'Memuat...',
      'error': 'Kesalahan',
      'success': 'Berhasil',
      'retry': 'Coba Lagi',

      // Messages
      'connectionSuccessful': 'Koneksi berhasil!',
      'connectionFailed': 'Koneksi gagal',
      'settingsSavedSuccessfully': 'Pengaturan berhasil disimpan',
      'failedToSaveSettings': 'Gagal menyimpan pengaturan',
      'settingsResetToDefault': 'Pengaturan dikembalikan ke default',
      'failedToResetSettings': 'Gagal mengembalikan pengaturan',

      // Quick Actions & Settings
      'quickActions': 'Aksi Cepat',
      'resetToDefault': 'Kembalikan ke Default',
      'resetToDefaultTitle': 'Kembalikan ke Default',
      'resetToDefaultConfirm':
          'Apakah Anda yakin ingin mengembalikan URL backend ke default?',
      'language': 'Bahasa',
      'indonesian': '🇮🇩 Bahasa Indonesia',
      'english': '🇺🇸 English',
      'about': 'Tentang',
      'appName': 'Nama Aplikasi',
      'version': 'Versi',
      'currentUrl': 'URL Saat Ini',
    },
  };

  static String get(String key, {String locale = 'en'}) {
    return _strings[locale]?[key] ?? _strings['en']?[key] ?? key;
  }

  static String getString(Locale locale, String key) {
    final lang = locale.languageCode;
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}

class LocalizationHelper {
  final Locale locale;

  LocalizationHelper(this.locale);

  // App
  String get products => AppStrings.getString(locale, 'products');
  String get orders => AppStrings.getString(locale, 'orders');
  String get settings => AppStrings.getString(locale, 'settings');

  // Products
  String get switchToListView =>
      AppStrings.getString(locale, 'switchToListView');
  String get switchToCardView =>
      AppStrings.getString(locale, 'switchToCardView');
  String get noProducts => AppStrings.getString(locale, 'noProducts');
  String get noProductsAvailable =>
      AppStrings.getString(locale, 'noProductsAvailable');

  // Orders
  String get newOrder => AppStrings.getString(locale, 'newOrder');
  String get switchToCalendarView =>
      AppStrings.getString(locale, 'switchToCalendarView');
  String get switchToListViewOrder =>
      AppStrings.getString(locale, 'switchToListViewOrder');
  String get noOrders => AppStrings.getString(locale, 'noOrders');
  String get noOrdersAvailable =>
      AppStrings.getString(locale, 'noOrdersAvailable');

  // Create/Edit Order
  String get createOrder => AppStrings.getString(locale, 'createOrder');
  String get customerName => AppStrings.getString(locale, 'customerName');
  String get selectPickupDate =>
      AppStrings.getString(locale, 'selectPickupDate');
  String get pickupDate => AppStrings.getString(locale, 'pickupDate');
  String get selectProducts => AppStrings.getString(locale, 'selectProducts');
  String get quantity => AppStrings.getString(locale, 'quantity');
  String get pleaseSelectAtLeastOneProduct =>
      AppStrings.getString(locale, 'pleaseSelectAtLeastOneProduct');
  String get createOrderError =>
      AppStrings.getString(locale, 'createOrderError');
  String get orderCreatedSuccessfully =>
      AppStrings.getString(locale, 'orderCreatedSuccessfully');
  String get orderCreationFailed =>
      AppStrings.getString(locale, 'orderCreationFailed');

  // Product Details
  String get productDetails => AppStrings.getString(locale, 'productDetails');
  String get price => AppStrings.getString(locale, 'price');
  String get stock => AppStrings.getString(locale, 'stock');
  String get description => AppStrings.getString(locale, 'description');
  String get loadingProductFailed =>
      AppStrings.getString(locale, 'loadingProductFailed');

  // Order Details
  String get orderDetails => AppStrings.getString(locale, 'orderDetails');
  String get status => AppStrings.getString(locale, 'status');
  String get totalAmount => AppStrings.getString(locale, 'totalAmount');
  String get printOrder => AppStrings.getString(locale, 'printOrder');
  String get loadingOrderFailed =>
      AppStrings.getString(locale, 'loadingOrderFailed');
  String get orderPrintedSuccessfully =>
      AppStrings.getString(locale, 'orderPrintedSuccessfully');
  String get orderPrintFailed =>
      AppStrings.getString(locale, 'orderPrintFailed');

  // Backend Configuration
  String get backendConfiguration =>
      AppStrings.getString(locale, 'backendConfiguration');
  String get backendConfigurationDesc =>
      AppStrings.getString(locale, 'backendConfigurationDesc');
  String get serverUrl => AppStrings.getString(locale, 'serverUrl');
  String get backendUrl => AppStrings.getString(locale, 'backendUrl');
  String get backendUrlHint => AppStrings.getString(locale, 'backendUrlHint');
  String get pleaseEnterBackendUrl =>
      AppStrings.getString(locale, 'pleaseEnterBackendUrl');
  String get urlMustStartWithHttp =>
      AppStrings.getString(locale, 'urlMustStartWithHttp');
  String get testConnection => AppStrings.getString(locale, 'testConnection');
  String get testing => AppStrings.getString(locale, 'testing');

  // Common
  String get save => AppStrings.getString(locale, 'save');
  String get cancel => AppStrings.getString(locale, 'cancel');
  String get delete => AppStrings.getString(locale, 'delete');
  String get edit => AppStrings.getString(locale, 'edit');
  String get add => AppStrings.getString(locale, 'add');
  String get confirm => AppStrings.getString(locale, 'confirm');
  String get reset => AppStrings.getString(locale, 'reset');
  String get loading => AppStrings.getString(locale, 'loading');
  String get error => AppStrings.getString(locale, 'error');
  String get success => AppStrings.getString(locale, 'success');
  String get retry => AppStrings.getString(locale, 'retry');

  // Messages
  String get connectionSuccessful =>
      AppStrings.getString(locale, 'connectionSuccessful');
  String get connectionFailed =>
      AppStrings.getString(locale, 'connectionFailed');
  String get settingsSavedSuccessfully =>
      AppStrings.getString(locale, 'settingsSavedSuccessfully');
  String get failedToSaveSettings =>
      AppStrings.getString(locale, 'failedToSaveSettings');
  String get settingsResetToDefault =>
      AppStrings.getString(locale, 'settingsResetToDefault');
  String get failedToResetSettings =>
      AppStrings.getString(locale, 'failedToResetSettings');

  // Quick Actions & Settings
  String get quickActions => AppStrings.getString(locale, 'quickActions');
  String get resetToDefault => AppStrings.getString(locale, 'resetToDefault');
  String get resetToDefaultTitle =>
      AppStrings.getString(locale, 'resetToDefaultTitle');
  String get resetToDefaultConfirm =>
      AppStrings.getString(locale, 'resetToDefaultConfirm');
  String get language => AppStrings.getString(locale, 'language');
  String get indonesian => AppStrings.getString(locale, 'indonesian');
  String get english => AppStrings.getString(locale, 'english');
  String get about => AppStrings.getString(locale, 'about');
  String get appName => AppStrings.getString(locale, 'appName');
  String get version => AppStrings.getString(locale, 'version');
  String get currentUrl => AppStrings.getString(locale, 'currentUrl');
}
