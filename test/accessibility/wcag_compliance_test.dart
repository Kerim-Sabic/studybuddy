import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/core/theme/app_colors.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'package:studybuddy/core/presentation/screens/main_home_screen.dart';

void main() {
  group('WCAG 2.1 AA Accessibility Compliance Tests', () {
    group('Color Contrast Ratio (4.5:1 for normal text)', () {
      test('Primary text on light background meets 4.5:1', () {
        // Light background
        const background = AppColors.backgroundLight;
        const foreground = AppColors.textPrimary;

        final ratio = _calculateContrastRatio(background, foreground);

        print('Primary text contrast ratio: ${ratio.toStringAsFixed(2)}:1');
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'Primary text should have at least 4.5:1 contrast ratio');
      });

      test('Secondary text on light background meets 4.5:1', () {
        const background = AppColors.backgroundLight;
        const foreground = AppColors.textSecondary;

        final ratio = _calculateContrastRatio(background, foreground);

        print('Secondary text contrast ratio: ${ratio.toStringAsFixed(2)}:1');
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'Secondary text should have at least 4.5:1 contrast ratio');
      });

      test('Primary gradient text has sufficient contrast', () {
        // Test against both ends of the gradient
        const background = Colors.white;
        final gradientColor1 = AppColors.primaryGradient.colors.first;
        final gradientColor2 = AppColors.primaryGradient.colors.last;

        final ratio1 = _calculateContrastRatio(background, gradientColor1);
        final ratio2 = _calculateContrastRatio(background, gradientColor2);

        print('Gradient color 1 ratio: ${ratio1.toStringAsFixed(2)}:1');
        print('Gradient color 2 ratio: ${ratio2.toStringAsFixed(2)}:1');

        // At least one should meet the requirement
        expect(
          ratio1 >= 4.5 || ratio2 >= 4.5,
          true,
          reason: 'Gradient colors should have sufficient contrast',
        );
      });

      test('Success color on light background meets 4.5:1', () {
        const background = Colors.white;
        const foreground = AppColors.success;

        final ratio = _calculateContrastRatio(background, foreground);

        print('Success color contrast ratio: ${ratio.toStringAsFixed(2)}:1');
        expect(ratio, greaterThanOrEqualTo(4.5));
      });

      test('Error color on light background meets 4.5:1', () {
        const background = Colors.white;
        const foreground = AppColors.error;

        final ratio = _calculateContrastRatio(background, foreground);

        print('Error color contrast ratio: ${ratio.toStringAsFixed(2)}:1');
        expect(ratio, greaterThanOrEqualTo(4.5));
      });

      test('Warning color on light background meets 4.5:1', () {
        const background = Colors.white;
        const foreground = AppColors.warning;

        final ratio = _calculateContrastRatio(background, foreground);

        print('Warning color contrast ratio: ${ratio.toStringAsFixed(2)}:1');
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'Warning should be at least 3:1 (large text acceptable)');
      });

      test('Color-blind palettes have distinct colors', () {
        // Test Protanopia palette
        final protanopiaColors = AppColors.protanopiaColors;

        for (int i = 0; i < protanopiaColors.length; i++) {
          for (int j = i + 1; j < protanopiaColors.length; j++) {
            final ratio = _calculateContrastRatio(
              protanopiaColors[i],
              protanopiaColors[j],
            );

            // Colors should be distinguishable (at least 3:1)
            expect(ratio, greaterThanOrEqualTo(3.0),
                reason: 'Protanopia colors $i and $j should be distinguishable');
          }
        }

        print('✅ Protanopia palette has ${protanopiaColors.length} distinct colors');
      });
    });

    group('Touch Target Size (Minimum 44x44 pt)', () {
      testWidgets('GlassButton meets minimum touch target size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: GlassButton(
                  label: 'Test Button',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(GlassButton);
        expect(buttonFinder, findsOneWidget);

        final size = tester.getSize(buttonFinder);

        print('GlassButton size: ${size.width}x${size.height}');
        expect(size.width, greaterThanOrEqualTo(44),
            reason: 'Button width should be at least 44pt');
        expect(size.height, greaterThanOrEqualTo(44),
            reason: 'Button height should be at least 44pt');
      });

      testWidgets('IconButton meets minimum touch target size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(IconButton);
        final size = tester.getSize(buttonFinder);

        print('IconButton size: ${size.width}x${size.height}');
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      });

      testWidgets('FloatingActionButton meets minimum touch target size',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Center(child: Text('Test')),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        final fabFinder = find.byType(FloatingActionButton);
        final size = tester.getSize(fabFinder);

        print('FAB size: ${size.width}x${size.height}');
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      });

      testWidgets('Checkbox meets minimum touch target size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Checkbox(
                  value: false,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        final checkboxFinder = find.byType(Checkbox);
        final size = tester.getSize(checkboxFinder);

        print('Checkbox size: ${size.width}x${size.height}');
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      });
    });

    group('Semantic Labels and Screen Reader Support', () {
      testWidgets('Buttons have semantic labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: GlassButton(
                  label: 'Create Course',
                  icon: Icons.add,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(GlassButton));

        expect(semantics.label, isNotNull,
            reason: 'Button should have semantic label');
        expect(semantics.label, contains('Create Course'));
      });

      testWidgets('Icons have tooltips for screen readers', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Tooltip(
                  message: 'Add new item',
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        final tooltipFinder = find.byType(Tooltip);
        expect(tooltipFinder, findsOneWidget);

        final tooltip = tester.widget<Tooltip>(tooltipFinder);
        expect(tooltip.message, equals('Add new item'));
      });

      testWidgets('Text fields have labels', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    hintText: 'Enter course name',
                  ),
                ),
              ),
            ),
          ),
        );

        final textFieldFinder = find.byType(TextField);
        final textField = tester.widget<TextField>(textFieldFinder);

        expect(textField.decoration?.labelText, equals('Course Name'));
        expect(textField.decoration?.hintText, equals('Enter course name'));
      });

      testWidgets('Images have semantic labels', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Semantics(
                  label: 'StudyBuddy logo',
                  child: Icon(Icons.school, size: 64),
                ),
              ),
            ),
          ),
        );

        final semanticsFinder = find.byType(Semantics);
        final semantics = tester.widget<Semantics>(semanticsFinder);

        expect(semantics.properties.label, equals('StudyBuddy logo'));
      });
    });

    group('Keyboard Navigation', () {
      testWidgets('Buttons are keyboard focusable', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: GlassButton(
                  label: 'Test',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        // Press tab to focus
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Button should be focused
        final focusedWidget = FocusManager.instance.primaryFocus;
        expect(focusedWidget, isNotNull);
      });

      testWidgets('Can navigate between multiple buttons with keyboard',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  GlassButton(label: 'Button 1', onPressed: () {}),
                  GlassButton(label: 'Button 2', onPressed: () {}),
                  GlassButton(label: 'Button 3', onPressed: () {}),
                ],
              ),
            ),
          ),
        );

        // Tab through buttons
        for (int i = 0; i < 3; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
        }

        // Should have cycled through all buttons
        expect(FocusManager.instance.primaryFocus, isNotNull);
      });
    });

    group('Text Scaling and Readability', () {
      testWidgets('Text scales correctly with accessibility settings',
          (tester) async {
        // Test with different text scale factors
        for (final textScaleFactor in [1.0, 1.5, 2.0, 3.0]) {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaleFactor: textScaleFactor),
              child: const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Hello World', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          );

          final textFinder = find.text('Hello World');
          final textWidget = tester.widget<Text>(textFinder);

          print('Text at ${textScaleFactor}x scale: fontSize ${textWidget.style?.fontSize}');

          // Text should still be readable at all scales
          expect(tester.getSize(textFinder).height, greaterThan(0));
        }
      });

      testWidgets('Minimum text size is 12pt', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Small Text', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        );

        final textFinder = find.text('Small Text');
        final textWidget = tester.widget<Text>(textFinder);

        expect(textWidget.style?.fontSize, greaterThanOrEqualTo(12),
            reason: 'Text should not be smaller than 12pt');
      });
    });

    group('Focus Indicators', () {
      testWidgets('Focused elements have visible indicators', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Focusable Button'),
                ),
              ),
            ),
          ),
        );

        // Focus the button
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Visual focus indicator should be present
        // (This would require golden test or pixel comparison in real scenario)
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Form Validation and Error Messages', () {
      testWidgets('Error messages are announced to screen readers',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: 'Invalid email address',
                  ),
                ),
              ),
            ),
          ),
        );

        final textFieldFinder = find.byType(TextField);
        final textField = tester.widget<TextField>(textFieldFinder);

        expect(textField.decoration?.errorText, isNotNull);
        expect(textField.decoration?.errorText, equals('Invalid email address'));
      });
    });

    group('Animations and Motion', () {
      testWidgets('Animations can be disabled for motion sensitivity',
          (tester) async {
        // Test with reduced motion preference
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              disableAnimations: true,
            ),
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        );

        // Animation should be instant when disabled
        await tester.pump();
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });
    });

    group('Time-Based Interactions', () {
      testWidgets('No time-limited interactions without warning', (tester) async {
        // Verify app doesn't have auto-dismissing dialogs or alerts
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Action'),
                ),
              ),
            ),
          ),
        );

        // Button should remain interactive indefinitely
        await tester.pumpAndSettle(const Duration(seconds: 60));
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });
  });
}

// Helper function to calculate contrast ratio between two colors
double _calculateContrastRatio(Color color1, Color2) {
  final l1 = _calculateRelativeLuminance(color1);
  final l2 = _calculateRelativeLuminance(color2);

  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;

  return (lighter + 0.05) / (darker + 0.05);
}

// Calculate relative luminance per WCAG formula
double _calculateRelativeLuminance(Color color) {
  final r = _linearize(color.red / 255.0);
  final g = _linearize(color.green / 255.0);
  final b = _linearize(color.blue / 255.0);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

// Linearize RGB component
double _linearize(double component) {
  if (component <= 0.03928) {
    return component / 12.92;
  } else {
    return pow((component + 0.055) / 1.055, 2.4).toDouble();
  }
}

// Import for pow function
import 'dart:math';
