import 'package:flutter/material.dart';
import 'package:lnq/models/product.dart';
import 'package:lnq/screens/products/product_details_screen.dart';
import 'package:lnq/screens/products/create_product_screen.dart';
import 'package:lnq/screens/products/edit_product_screen.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/products/products_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/settings/settings_screen.dart';
import '../l10n/strings.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Attempt backend discovery on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _discoverBackend();
    });
  }

  Future<void> _discoverBackend() async {
    final settings = context.read<SettingsProvider>();
    await settings.attemptBackendDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;

    return MaterialApp(
      title: 'LNQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: locale,
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/product_details') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          );
        }
        if (settings.name == '/create_product') {
          return MaterialPageRoute(
            builder: (context) => const CreateProductScreen(),
          );
        }
        if (settings.name == '/edit_product') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => EditProductScreen(product: product),
          );
        }
        // Add other dynamic routes here if needed
        return null;
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  static const List<Widget> _screens = [
    ProductsScreen(),
    OrdersScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: AppConstants.fabAnimationDuration,
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fabAnimationController.reset();
    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppConstants.screenTransitionDuration,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.primary,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined),
              selectedIcon: const Icon(Icons.shopping_bag),
              label: AppStrings.trWatch(context, 'products'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: AppStrings.trWatch(context, 'orders'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: AppStrings.trWatch(context, 'settings'),
            ),
          ],
        ),
      ),
    );
  }
}
