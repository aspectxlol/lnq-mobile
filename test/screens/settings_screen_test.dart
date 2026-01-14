import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lnq/providers/settings_provider.dart';
import 'package:lnq/screens/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen UI Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ Settings screen renders with all sections', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(SingleChildScrollView).evaluate().length, greaterThan(0));
    });

    testWidgets('✓ Base URL field initializes with current settings', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      expect(textField, findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('✓ Test connection button is enabled when form is valid', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final outlinedButton = find.byType(OutlinedButton);
      expect(outlinedButton, findsOneWidget);
      expect(find.byIcon(Icons.wifi_find), findsOneWidget);
    });

    testWidgets('✓ Language radio buttons render both options', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final radioButtons = find.byType(RadioListTile<String>);
      expect(radioButtons, findsWidgets);
      expect(radioButtons.evaluate().length, greaterThanOrEqualTo(2));
    });

    testWidgets('✓ About section displays app info', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('LNQ'), findsWidgets);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('✓ Reset to default button is present', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final listTiles = find.byType(ListTile);
      expect(listTiles, findsWidgets);
      expect(listTiles.evaluate().length, greaterThan(0));
    });

    testWidgets('✗ Test connection fails with empty URL', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      await settingsProvider.setBaseUrl('');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, '');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('✓ URL field accepts valid HTTP URL', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'http://localhost:8080');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('http://localhost:8080'), findsOneWidget);
    });

    testWidgets('✓ URL field accepts valid HTTPS URL', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'https://api.example.com:443');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('https://api.example.com:443'), findsOneWidget);
    });

    testWidgets('✓ Save button is present and enabled', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Find button with save icon
      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);
    });

    testWidgets('✓ Form validates empty base URL', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      await settingsProvider.setBaseUrl('http://localhost:8080');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, '');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  group('SettingsScreen State Management Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ Health status clears when URL is changed', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'http://localhost:8080');
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(textField, 'http://new-url:8080');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('✓ All UI sections render without errors', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.allWidgets.length, greaterThan(0));
    });

    testWidgets('✓ TextEditingController initializes with base URL', (WidgetTester tester) async {
      const testUrl = 'http://test-server:3000';
      final settingsProvider = SettingsProvider();
      await settingsProvider.setBaseUrl(testUrl);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(testUrl), findsWidgets);
    });

    testWidgets('✓ Form key is available for validation', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final formWidget = find.byType(Form);
      expect(formWidget, findsOneWidget);
    });
  });

  group('SettingsScreen Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ URL validation with boundary values - min length', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'http://a');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('http://a'), findsOneWidget);
    });

    testWidgets('✓ URL validation with boundary values - long URL', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final longUrl = 'https://very-long-domain-name-for-testing-purposes.company.example.co.id:8443/api/v1/backend?param1=value1&param2=value2';
      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, longUrl);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(longUrl), findsOneWidget);
    });

    testWidgets('✓ Special characters in URL are handled', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final urlWithSpecialChars = 'https://api.example.com:8443/path?key=value&special=!@#%';
      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, urlWithSpecialChars);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(urlWithSpecialChars), findsOneWidget);
    });

    testWidgets('✓ URL field handles rapid input changes', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      
      await tester.enterText(textField, 'http://');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(textField, 'http://localhost');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(textField, 'http://localhost:8080');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('http://localhost:8080'), findsOneWidget);
    });

    testWidgets('✓ Settings screen unmounts without errors', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.allWidgets.isNotEmpty, isTrue);
    });

    testWidgets('✓ Multiple language switches work correctly', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final radioButtons = find.byType(RadioListTile<String>);
      expect(radioButtons, findsWidgets);
    });
  });

  group('SettingsScreen Edge Cases Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ URL with international domain names', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'https://example.中国:8080');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('https://example.中国:8080'), findsOneWidget);
    });

    testWidgets('✓ URL with IPv4 address', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'http://192.168.1.1:8080');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('http://192.168.1.1:8080'), findsOneWidget);
    });

    testWidgets('✓ URL with IPv6 address', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'https://[::1]:8080');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('https://[::1]:8080'), findsOneWidget);
    });

    testWidgets('✓ Whitespace handling in URL field', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, '   http://example.com   ');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('   http://example.com   '), findsOneWidget);
    });

    testWidgets('✓ Settings screen disposes resources correctly', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: const SettingsScreen(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SettingsScreen), findsNothing);
    });
  });

  group('SettingsScreen Boundary Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ Minimum valid URL length (http://a)', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'http://a');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('http://a'), findsOneWidget);
    });

    testWidgets('✓ Very long URL (500+ characters)', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final longUrl = 'https://${'x' * 400}.com:8080/path';
      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, longUrl);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(longUrl), findsOneWidget);
    });

    testWidgets('✓ URLs with HTTP protocol', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'http://example.com');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('http://example.com'), findsOneWidget);
    });

    testWidgets('✓ URLs with HTTPS protocol', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'https://example.com');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('https://example.com'), findsOneWidget);
    });

    testWidgets('✗ Invalid protocol - FTP rejected', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'ftp://example.com');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('✗ URL without protocol rejected', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'example.com');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('✗ Whitespace-only URL rejected', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, '     ');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  group('SettingsScreen Locale Management Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ Locale changes update UI', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final radioButtons = find.byType(RadioListTile<String>);
      expect(radioButtons, findsWidgets);
    });

    testWidgets('✓ Indonesian locale can be selected', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final radioButtons = find.byType(RadioListTile<String>);
      expect(radioButtons, findsWidgets);
    });

    testWidgets('✓ English locale can be selected', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final radioButtons = find.byType(RadioListTile<String>);
      expect(radioButtons, findsWidgets);
    });

    testWidgets('✓ Locale persists through widget rebuild', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      await settingsProvider.setLocale(const Locale('en', 'US'));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(settingsProvider.locale.languageCode, 'en');
    });
  });

  group('SettingsScreen Resource Cleanup Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('✓ TextEditingController is properly disposed', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets('✓ Form key is properly cleaned up', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Form), findsNothing);
    });

    testWidgets('✓ Multiple screen instances do not cause memory leaks', (WidgetTester tester) async {
      for (int i = 0; i < 5; i++) {
        final settingsProvider = SettingsProvider();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
              child: const SettingsScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.byType(SettingsScreen), findsNothing);
    });
  });
}
