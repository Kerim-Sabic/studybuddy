# StudyBuddy Test Suite

This directory contains comprehensive unit, widget, and integration tests for the StudyBuddy application.

## Test Coverage

### Phase 3 Testing Implementation

Phase 3 introduces comprehensive testing with the following coverage:

#### 1. Domain Entity Tests

**Assignment Tests** (`test/features/scheduling/domain/entities/assignment_test.dart`)
- ✅ Assignment creation with required and optional fields
- ✅ `isOverdue` property calculation
- ✅ `daysUntilDue` and `hoursUntilDue` calculations
- ✅ `isDueSoon` property logic
- ✅ `completionPercentage` calculation with various grade scenarios
- ✅ Equality comparison
- ✅ Enum validation (AssignmentType, Priority)

**Course Tests** (`test/features/scheduling/domain/entities/course_test.dart`)
- ✅ Course creation with sessions
- ✅ ClassSession day name mapping
- ✅ ClassSession duration calculations
- ✅ ClassSession time range formatting
- ✅ Equality comparison

**Task Tests** (`test/features/tasks/domain/entities/task_test.dart`)
- ✅ Task creation with subtasks
- ✅ `completionPercentage` based on subtasks
- ✅ `areAllSubtasksCompleted` property
- ✅ RecurrenceRule creation and next occurrence calculation
- ✅ Daily, weekly, monthly, yearly recurrence patterns
- ✅ TaskCategory entity
- ✅ SubTask entity

**Goal Tests** (`test/features/goals/domain/entities/goal_test.dart`)
- ✅ Goal creation with milestones
- ✅ `completionPercentage` calculation
- ✅ `timeProgressPercentage` calculation
- ✅ `isOnTrack` property (completion vs time progress)
- ✅ `daysRemaining` calculation
- ✅ `recommendedDailyProgress` calculation
- ✅ Milestone entity
- ✅ Enum validation (GoalType, GoalCategory)

#### 2. Business Logic Tests

**Smart Scheduling Service** (`test/features/scheduling/domain/usecases/smart_scheduling_service_test.dart`)
- ✅ Empty schedule generation
- ✅ Schedule generation for assignments and tasks
- ✅ Priority-based scheduling (urgent items first)
- ✅ Break inclusion (Pomodoro technique)
- ✅ Avoiding class session conflicts
- ✅ Respecting user preferences (wake/sleep times, break durations)
- ✅ Interleaving subjects
- ✅ Splitting long assignments into multiple sessions
- ✅ Spaced repetition across days
- ✅ Skipping completed items and tasks without due dates
- ✅ UserPreferences defaults and customization
- ✅ StudyBlock end time calculation

#### 3. Widget Tests

**Glass Components** (`test/core/widgets/glass_card_test.dart`)
- ✅ GlassCard rendering and customization (blur, opacity, border radius, padding)
- ✅ GlassCard tap handling
- ✅ GlassButton label display and onPressed callback
- ✅ GlassButton loading state
- ✅ GlassButton disabled state
- ✅ GlassButton icon support
- ✅ GlassButton fullWidth mode
- ✅ GlassContainer sizing
- ✅ GlassAppBar with title, leading, and actions
- ✅ GlassBottomNavigationBar item display and tap handling
- ✅ GlassDialog with title, content, and actions
- ✅ GlassDialog dismissal

## Test Statistics

- **Total Test Files**: 6
- **Estimated Test Cases**: 150+
- **Test Categories**:
  - Domain Entity Tests: 4 files
  - Business Logic Tests: 1 file
  - Widget Tests: 1 file

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/features/scheduling/domain/entities/assignment_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Generate HTML Coverage Report

```bash
# Generate coverage
flutter test --coverage

# Convert to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### Run Tests in Watch Mode (VS Code)

If using VS Code, you can run tests in watch mode by:
1. Install the "Flutter" extension
2. Open a test file
3. Click the "Run" button above each test group
4. Tests will re-run automatically when you save changes

### Run Tests with Verbose Output

```bash
flutter test --reporter expanded
```

## Test Structure

Each test file follows this structure:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/...';

void main() {
  group('FeatureName', () {
    late ServiceUnderTest service;

    setUp(() {
      service = ServiceUnderTest();
    });

    group('Method or Property', () {
      test('specific behavior description', () {
        // Arrange
        final input = ...;

        // Act
        final result = service.method(input);

        // Assert
        expect(result, expectedValue);
      });
    });
  });
}
```

## Writing New Tests

### Unit Tests for Domain Entities

```dart
test('calculates property correctly', () {
  final entity = Entity(
    field: value,
  );

  expect(entity.calculatedProperty, expectedValue);
});
```

### Widget Tests

```dart
testWidgets('renders widget correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MyWidget(),
      ),
    ),
  );

  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Testing Async Code

```dart
test('async operation completes successfully', () async {
  final result = await service.asyncMethod();

  expect(result, expectedValue);
});
```

## Code Coverage Goals

- **Target Coverage**: 80%+
- **Critical Paths**: 100% (payment processing, data persistence)
- **UI Components**: 70%+ (focus on logic, not styling)

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Test Best Practices

1. **AAA Pattern**: Arrange, Act, Assert
2. **One Assertion Per Test**: Focus each test on one behavior
3. **Descriptive Names**: Test names should describe the expected behavior
4. **Independent Tests**: Tests should not depend on each other
5. **Fast Tests**: Keep tests fast by avoiding unnecessary delays
6. **Mock External Dependencies**: Use mocks for databases, APIs, etc.

## Troubleshooting

### Tests Fail Due to Missing Dependencies

```bash
flutter pub get
```

### Widget Tests Fail with "Null check operator"

Ensure you're wrapping widgets in `MaterialApp`:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: YourWidget(),
    ),
  ),
);
```

### Async Tests Timeout

Increase the timeout:

```dart
test('long running test', () async {
  // Test code
}, timeout: Timeout(Duration(minutes: 2)));
```

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

## Next Steps

### Phase 4 Testing Priorities

1. **Provider Tests**: Test Riverpod providers with mocked dependencies
2. **Integration Tests**: End-to-end user flows
3. **Performance Tests**: Ensure smooth animations and quick load times
4. **Accessibility Tests**: Validate WCAG 2.1 AA compliance
5. **Golden Tests**: Visual regression testing for UI components

---

**Test Coverage Target**: 80%+
**Current Status**: Phase 3 Complete ✅
**Last Updated**: 2024-11-16
