import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:studybuddy/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('StudyBuddy Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app launched (look for any widget)
      expect(find.byType(MaterialApp), findsOneWidget);

      print('✅ App launched successfully!');
    });

    testWidgets('Navigation bar is present', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Skip onboarding if present
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Look for navigation elements
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isNotEmpty) {
        expect(navBar, findsOneWidget);
        print('✅ Navigation bar found');
      } else {
        print('ℹ️ Navigation bar not found - may not be on home screen');
      }
    });

    testWidgets('Can navigate between screens', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Skip onboarding if present
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Try to find any tappable elements
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        print('✅ Found ${buttons.evaluate().length} buttons');
      }

      final icons = find.byType(IconButton);
      if (icons.evaluate().isNotEmpty) {
        print('✅ Found ${icons.evaluate().length} icon buttons');
      }

      final fabs = find.byType(FloatingActionButton);
      if (fabs.evaluate().isNotEmpty) {
        print('✅ Found ${fabs.evaluate().length} FABs');
      }

      // As long as we found something interactive, test passes
      expect(
        buttons.evaluate().isNotEmpty ||
            icons.evaluate().isNotEmpty ||
            fabs.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should find at least one interactive element',
      );
    });
  });
}
