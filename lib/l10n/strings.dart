import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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
      'failedToLoadProduct': 'Failed to load product',
      'goBack': 'Go Back',
      'productId': 'Product ID',
      'created': 'Created',
      'addToOrder': 'Add to Order',

      // Orders Screen
      'newOrder': 'New Order',
      'switchToCalendarView': 'Switch to Calendar View',
      'switchToListViewOrder': 'Switch to List View',
      'noOrders': 'No Orders',
      'noOrdersAvailable': 'No orders available at the moment.',
      'createFirstOrder': 'Create your first order to get started.',
      'selectADate': 'Select a date',
      'order': 'order',
      'ordersPlural': 'orders',
      'noOrdersScheduled': 'No orders scheduled for this date.',
      'selectDateToView': 'Select a date to view orders.',
      'scheduled': 'Scheduled',
      'new': 'New',
      'pickup': 'Pickup',
      'items': 'items',

      // Create/Edit Order
      'createOrder': 'Create Order',
      'editOrder': 'Edit Order',
      'customerName': 'Customer Name',
      'enterCustomerName': 'Enter customer name',
      'pleaseEnterCustomerName': 'Please enter customer name',
      'selectPickupDate': 'Select Pickup Date',
      'pickupDate': 'Pickup Date',
      'pickupDateOptional': 'Pickup Date (Optional)',
      'noPickupDateSet': 'No pickup date set',
      'clearPickupDate': 'Clear pickup date',
      'orderNotesOptional': 'Order Notes (Optional)',
      'orderNotesHint': 'e.g., Call when ready, Rush order',
      'selectProducts': 'Select Products',
      'orderItems': 'Order Items',
      'addItem': 'Add Item',
      'noItemsAdded': 'No items added',
      'tapAddItem': 'Tap "Add Item" to select products',
      'quantity': 'Quantity',
      'pleaseSelectAtLeastOneProduct': 'Please select at least one product',
      'pleaseAddAtLeastOneItem': 'Please add at least one item',
      'createOrderError': 'Error creating order',
      'orderCreatedSuccessfully': 'Order created successfully',
      'orderCreationFailed': 'Failed to create order',
      'creating': 'Creating...',
      'saving': 'Saving...',
      'saveChanges': 'Save Changes',
      'addProductsBeforeOrders': 'Add products before creating orders.',

      // Add Product Dialog
      'addProduct': 'Add Product',
      'selectProduct': 'Select Product',
      'allProductsAdded': 'All products have been added',
      'itemNotesOptional': 'Item Notes (Optional)',
      'itemNotesHint': 'e.g., Extra hot, No sugar',
      'subtotal': 'Subtotal',

      // Product Details
      'productDetails': 'Product Details',
      'price': 'Price',
      'stock': 'Stock',
      'description': 'Description',
      'loadingProductFailed': 'Failed to load product',

      // Order Details
      'orderDetails': 'Order Details',
      'orderInformation': 'Order Information',
      'orderNotes': 'Order Notes',
      'status': 'Status',
      'total': 'Total',
      'totalAmount': 'Total Amount',
      'printOrder': 'Print Order',
      'printing': 'Printing...',
      'orderSentToPrinter': 'Order sent to printer',
      'failedToPrint': 'Failed to print',
      'loadingOrderFailed': 'Failed to load order',
      'orderPrintedSuccessfully': 'Order printed successfully',
      'orderPrintFailed': 'Failed to print order',
      'deleteOrder': 'Delete Order',
      'deleteOrderConfirm': 'Are you sure you want to delete this order?',
      'failedToDelete': 'Failed to delete',
      'orderUpdatedSuccessfully': 'Order updated successfully',
      'failedToUpdateOrder': 'Failed to update order',
      'failedToLoadProducts': 'Failed to load products',

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
      'failedToLoadProduct': 'Gagal memuat produk',
      'goBack': 'Kembali',
      'productId': 'ID Produk',
      'created': 'Dibuat',
      'addToOrder': 'Tambah ke Pesanan',

      // Orders Screen
      'newOrder': 'Pesanan Baru',
      'switchToCalendarView': 'Beralih ke Tampilan Kalender',
      'switchToListViewOrder': 'Beralih ke Tampilan Daftar',
      'noOrders': 'Tidak Ada Pesanan',
      'noOrdersAvailable': 'Tidak ada pesanan tersedia saat ini.',
      'createFirstOrder': 'Buat pesanan pertama Anda untuk memulai.',
      'selectADate': 'Pilih tanggal',
      'order': 'pesanan',
      'ordersPlural': 'pesanan',
      'noOrdersScheduled': 'Tidak ada pesanan terjadwal untuk tanggal ini.',
      'selectDateToView': 'Pilih tanggal untuk melihat pesanan.',
      'scheduled': 'Terjadwal',
      'new': 'Baru',
      'pickup': 'Pengambilan',
      'items': 'item',

      // Create/Edit Order
      'createOrder': 'Buat Pesanan',
      'editOrder': 'Edit Pesanan',
      'customerName': 'Nama Pelanggan',
      'enterCustomerName': 'Masukkan nama pelanggan',
      'pleaseEnterCustomerName': 'Mohon masukkan nama pelanggan',
      'selectPickupDate': 'Pilih Tanggal Pengambilan',
      'pickupDate': 'Tanggal Pengambilan',
      'pickupDateOptional': 'Tanggal Pengambilan (Opsional)',
      'noPickupDateSet': 'Tanggal pengambilan belum diatur',
      'clearPickupDate': 'Hapus tanggal pengambilan',
      'orderNotesOptional': 'Catatan Pesanan (Opsional)',
      'orderNotesHint': 'cth., Hubungi saat siap, Pesanan cepat',
      'selectProducts': 'Pilih Produk',
      'orderItems': 'Item Pesanan',
      'addItem': 'Tambah Item',
      'noItemsAdded': 'Belum ada item',
      'tapAddItem': 'Ketuk "Tambah Item" untuk memilih produk',
      'quantity': 'Jumlah',
      'pleaseSelectAtLeastOneProduct': 'Mohon pilih setidaknya satu produk',
      'pleaseAddAtLeastOneItem': 'Mohon tambah setidaknya satu item',
      'createOrderError': 'Kesalahan membuat pesanan',
      'orderCreatedSuccessfully': 'Pesanan berhasil dibuat',
      'orderCreationFailed': 'Gagal membuat pesanan',
      'creating': 'Membuat...',
      'saving': 'Menyimpan...',
      'saveChanges': 'Simpan Perubahan',
      'addProductsBeforeOrders': 'Tambah produk sebelum membuat pesanan.',

      // Add Product Dialog
      'addProduct': 'Tambah Produk',
      'selectProduct': 'Pilih Produk',
      'allProductsAdded': 'Semua produk telah ditambahkan',
      'itemNotesOptional': 'Catatan Item (Opsional)',
      'itemNotesHint': 'cth., Ekstra panas, Tanpa gula',
      'subtotal': 'Subtotal',

      // Product Details
      'productDetails': 'Detail Produk',
      'price': 'Harga',
      'stock': 'Stok',
      'description': 'Deskripsi',
      'loadingProductFailed': 'Gagal memuat produk',

      // Order Details
      'orderDetails': 'Detail Pesanan',
      'orderInformation': 'Informasi Pesanan',
      'orderNotes': 'Catatan Pesanan',
      'status': 'Status',
      'total': 'Total',
      'totalAmount': 'Jumlah Total',
      'printOrder': 'Cetak Pesanan',
      'printing': 'Mencetak...',
      'orderSentToPrinter': 'Pesanan dikirim ke printer',
      'failedToPrint': 'Gagal mencetak',
      'loadingOrderFailed': 'Gagal memuat pesanan',
      'orderPrintedSuccessfully': 'Pesanan berhasil dicetak',
      'orderPrintFailed': 'Gagal mencetak pesanan',
      'deleteOrder': 'Hapus Pesanan',
      'deleteOrderConfirm': 'Apakah Anda yakin ingin menghapus pesanan ini?',
      'failedToDelete': 'Gagal menghapus',
      'orderUpdatedSuccessfully': 'Pesanan berhasil diperbarui',
      'failedToUpdateOrder': 'Gagal memperbarui pesanan',
      'failedToLoadProducts': 'Gagal memuat produk',

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

  /// Convenience method to get a translated string using the locale from SettingsProvider
  static String tr(BuildContext context, String key) {
    final locale = context.read<SettingsProvider>().locale;
    return getString(locale, key);
  }

  /// Convenience method for watching locale changes (use in build methods)
  static String trWatch(BuildContext context, String key) {
    final locale = context.watch<SettingsProvider>().locale;
    return getString(locale, key);
  }
}
