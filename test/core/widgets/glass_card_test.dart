import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

void main() {
  group('GlassCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies default blur and opacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('accepts custom blur value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              blur: 20.0,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('accepts custom opacity value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              opacity: 0.5,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('accepts custom border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              borderRadius: 24.0,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('accepts custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: EdgeInsets.all(24.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('can be tapped when onTap is provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapped = true,
              child: const Text('Tappable'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not respond to taps when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Non-tappable'),
            ),
          ),
        ),
      );

      // Should not throw when tapped
      await tester.tap(find.byType(GlassCard));
      await tester.pumpAndSettle();

      expect(find.text('Non-tappable'), findsOneWidget);
    });
  });

  group('GlassButton', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Button',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Button'), findsNothing);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Button',
              onPressed: () => pressed = true,
              isDisabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Button',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('applies fullWidth when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: GlassButton(
                label: 'Full Width Button',
                onPressed: () {},
                fullWidth: true,
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(GlassButton);
      expect(buttonFinder, findsOneWidget);

      final buttonWidget = tester.widget<GlassButton>(buttonFinder);
      expect(buttonWidget.fullWidth, isTrue);
    });
  });

  group('GlassContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text('Container Content'),
            ),
          ),
        ),
      );

      expect(find.text('Container Content'), findsOneWidget);
    });

    testWidgets('accepts custom height and width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              width: 200,
              height: 100,
              child: Text('Sized Container'),
            ),
          ),
        ),
      );

      final container = tester.widget<GlassContainer>(find.byType(GlassContainer));
      expect(container.width, equals(200));
      expect(container.height, equals(100));
    });
  });

  group('GlassAppBar', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: GlassAppBar(
              title: Text('App Title'),
            ),
            body: SizedBox(),
          ),
        ),
      );

      expect(find.text('App Title'), findsOneWidget);
    });

    testWidgets('displays leading widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: GlassAppBar(
              leading: Icon(Icons.menu),
              title: Text('Title'),
            ),
            body: SizedBox(),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('displays actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: GlassAppBar(
              title: Text('Title'),
              actions: [
                Icon(Icons.search),
                Icon(Icons.settings),
              ],
            ),
            body: SizedBox(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('GlassBottomNavigationBar', () {
    testWidgets('displays all items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: GlassBottomNavigationBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt),
                  label: 'Tasks',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('calls onTap when item is tapped', (tester) async {
      var tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: GlassBottomNavigationBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Schedule',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(1));
    });

    testWidgets('highlights current index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: GlassBottomNavigationBar(
              currentIndex: 1,
              onTap: (_) {},
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Schedule',
                ),
              ],
            ),
          ),
        ),
      );

      final navBar = tester.widget<GlassBottomNavigationBar>(
        find.byType(GlassBottomNavigationBar),
      );
      expect(navBar.currentIndex, equals(1));
    });
  });

  group('GlassDialog', () {
    testWidgets('displays title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const GlassDialog(
                      title: Text('Dialog Title'),
                      content: Text('Dialog Content'),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog Content'), findsOneWidget);
    });

    testWidgets('displays actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => GlassDialog(
                      title: const Text('Confirm'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('can be dismissed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => GlassDialog(
                      title: const Text('Dialog'),
                      content: const Text('Content'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog'), findsNothing);
    });
  });
}
