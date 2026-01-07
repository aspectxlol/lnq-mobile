// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'LNQ';

  @override
  String get products => 'Produk';

  @override
  String get orders => 'Pesanan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get noProducts => 'Tidak ada produk tersedia';

  @override
  String get noOrders => 'Belum ada pesanan';

  @override
  String get createOrder => 'Buat Pesanan';

  @override
  String get orderDetails => 'Detail Pesanan';

  @override
  String get productDetails => 'Detail Produk';

  @override
  String get price => 'Harga';

  @override
  String get stock => 'Stok';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Tambah';

  @override
  String get search => 'Cari';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Urutkan';

  @override
  String get loading => 'Memuat...';

  @override
  String get error => 'Kesalahan';

  @override
  String get success => 'Berhasil';

  @override
  String get total => 'Total';

  @override
  String get quantity => 'Jumlah';

  @override
  String get date => 'Tanggal';

  @override
  String get status => 'Status';

  @override
  String get serverUrl => 'URL Server';

  @override
  String get language => 'Bahasa';

  @override
  String get theme => 'Tema';

  @override
  String get version => 'Versi';

  @override
  String get backendConfiguration => 'Konfigurasi Backend';

  @override
  String get backendConfigurationDesc =>
      'Atur URL server backend untuk aplikasi.';

  @override
  String get backendUrl => 'URL Backend';

  @override
  String get backendUrlHint => 'http://localhost:3000';

  @override
  String get pleaseEnterBackendUrl => 'Mohon masukkan URL backend';

  @override
  String get urlMustStartWithHttp =>
      'URL harus dimulai dengan http:// atau https://';

  @override
  String get testConnection => 'Tes Koneksi';

  @override
  String get testing => 'Menguji...';

  @override
  String connectionSuccessful(Object db, Object minio) {
    return 'Koneksi berhasil!\nDB: $db, MinIO: $minio';
  }

  @override
  String connectionFailed(Object error) {
    return 'Koneksi gagal: $error';
  }

  @override
  String get settingsSavedSuccessfully => 'Pengaturan berhasil disimpan';

  @override
  String failedToSaveSettings(Object error) {
    return 'Gagal menyimpan pengaturan: $error';
  }

  @override
  String get quickActions => 'Aksi Cepat';

  @override
  String get resetToDefault => 'Kembalikan ke Default';

  @override
  String get resetToDefaultTitle => 'Kembalikan ke Default';

  @override
  String get resetToDefaultConfirm =>
      'Apakah Anda yakin ingin mengembalikan URL backend ke default?';

  @override
  String get reset => 'Kembalikan';

  @override
  String get settingsResetToDefault => 'Pengaturan dikembalikan ke default';

  @override
  String failedToResetSettings(Object error) {
    return 'Gagal mengembalikan pengaturan: $error';
  }

  @override
  String get indonesian => '🇮🇩 Bahasa Indonesia';

  @override
  String get english => '🇺🇸 English';

  @override
  String get about => 'Tentang';

  @override
  String get appName => 'Nama Aplikasi';

  @override
  String get currentUrl => 'URL Saat Ini';
}
