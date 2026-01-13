import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/products_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;
    
    return MaterialApp(
      title: 'LNQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: locale,
      home: const MainScreen(),
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
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _screens = const [
    ProductsScreen(),
    OrdersScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
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
        duration: const Duration(milliseconds: 300),
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
          indicatorColor: AppColors.primary.withOpacity(0.2),
          height: 70,
          destinations: [
            NavigationDestination(
              icon: Icon(
                _currentIndex == 0
                    ? Icons.shopping_bag
                    : Icons.shopping_bag_outlined,
                color: _currentIndex == 0
                    ? AppColors.primary
                    : AppColors.mutedForeground,
              ),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(
                _currentIndex == 1
                    ? Icons.receipt_long
                    : Icons.receipt_long_outlined,
                color: _currentIndex == 1
                    ? AppColors.primary
                    : AppColors.mutedForeground,
              ),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(
                _currentIndex == 2 ? Icons.settings : Icons.settings_outlined,
                color: _currentIndex == 2
                    ? AppColors.primary
                    : AppColors.mutedForeground,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
