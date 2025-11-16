# Contributing to StudyBuddy

Thank you for your interest in contributing to StudyBuddy! We're excited to have you join our mission to create the best study helper application ever built.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Project Structure](#project-structure)
5. [Coding Standards](#coding-standards)
6. [Making Changes](#making-changes)
7. [Testing](#testing)
8. [Submitting Changes](#submitting-changes)
9. [Review Process](#review-process)

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow:

- **Be respectful**: Treat everyone with respect and kindness
- **Be collaborative**: Work together and help each other
- **Be inclusive**: Welcome people of all backgrounds and experience levels
- **Be patient**: Remember that people have different learning curves
- **Be constructive**: Provide helpful feedback and suggestions

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter**: Version 3.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart**: Comes with Flutter
- **Git**: For version control
- **IDE**: VS Code (recommended) or Android Studio
- **Firebase CLI**: For backend features
- **Node.js**: For Firebase Functions

### First-Time Setup

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/studybuddy.git
   cd studybuddy
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/original/studybuddy.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

6. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

7. **Run the app**
   ```bash
   flutter run
   ```

## Development Setup

### IDE Configuration

#### VS Code Extensions

Install these recommended extensions:

- **Dart** (Dart-Code.dart-code)
- **Flutter** (Dart-Code.flutter)
- **Awesome Flutter Snippets** (Nash.awesome-flutter-snippets)
- **Pubspec Assist** (jeroen-meijer.pubspec-assist)
- **Error Lens** (usernamehw.errorlens)
- **GitLens** (eamodio.gitlens)

#### VS Code Settings

Add to your `.vscode/settings.json`:

```json
{
  "dart.lineLength": 100,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": false
}
```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication, Firestore, Storage, and Cloud Functions
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories
5. Run `flutterfire configure` to generate `firebase_options.dart`

## Project Structure

```
lib/
├── core/                 # Core application components
│   ├── theme/           # Theme and styling
│   ├── widgets/         # Reusable widgets
│   ├── utils/           # Utilities and helpers
│   ├── constants/       # App-wide constants
│   └── router/          # Navigation configuration
├── features/            # Feature modules (Clean Architecture)
│   ├── auth/
│   │   ├── data/       # Data sources and repositories
│   │   ├── domain/     # Entities and use cases
│   │   └── presentation/ # UI and state management
│   ├── scheduling/
│   ├── flashcards/
│   └── ...
└── main.dart           # Entry point
```

### Feature Structure

Each feature follows Clean Architecture:

```
feature_name/
├── data/
│   ├── datasources/    # API, local DB
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business objects
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic
└── presentation/
    ├── providers/      # Riverpod providers
    ├── screens/        # Full-screen pages
    └── widgets/        # Feature-specific widgets
```

## Coding Standards

### Dart Style Guide

We follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style) with some additions:

#### Naming Conventions

- **Classes**: `PascalCase` (e.g., `FlashcardService`)
- **Variables/Functions**: `camelCase` (e.g., `getUserProfile`)
- **Constants**: `lowerCamelCase` (e.g., `defaultTimeout`)
- **Private members**: Prefix with `_` (e.g., `_internalMethod`)
- **Files**: `snake_case` (e.g., `user_profile.dart`)

#### Code Organization

```dart
// 1. Imports - organized by type
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../models/user.dart';

// 2. Provider declarations
final userProvider = StateProvider<User?>((ref) => null);

// 3. Class declaration
class UserProfile extends ConsumerWidget {
  // 4. Constructor
  const UserProfile({super.key});

  // 5. Build method
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation
  }

  // 6. Helper methods
  void _handleAction() {
    // Implementation
  }
}
```

#### Comments and Documentation

- **Public APIs**: Always document with `///` comments
- **Complex logic**: Add inline comments explaining "why", not "what"
- **TODOs**: Use `// TODO: Description` format

```dart
/// Calculates the next review date using spaced repetition algorithm.
///
/// The interval is determined by the user's performance on previous reviews.
/// Returns a [DateTime] representing when the card should be reviewed next.
DateTime calculateNextReview({
  required int currentBox,
  required double easeFactor,
}) {
  // Implementation
}
```

### Widget Best Practices

#### Use `const` Constructors

```dart
// Good
const Text('Hello');
const SizedBox(height: 16);

// Bad
Text('Hello');
SizedBox(height: 16);
```

#### Extract Complex Widgets

```dart
// Good
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(user.photoUrl),
    );
  }
}

// Bad - inline complex widget
CircleAvatar(
  backgroundImage: NetworkImage(user.photoUrl),
  child: user.isOnline
    ? Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          // ...many lines
        ),
      )
    : null,
)
```

#### Use Trailing Commas

```dart
// Good - easier to read and better diffs
Column(
  children: [
    Text('First'),
    Text('Second'),
    Text('Third'),
  ],
)

// Bad
Column(children: [Text('First'), Text('Second'), Text('Third')])
```

### State Management with Riverpod

We use Riverpod for state management. Follow these patterns:

#### Provider Types

```dart
// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Computed state
final doubledProvider = Provider<int>((ref) {
  final count = ref.watch(counterProvider);
  return count * 2;
});

// Async data
final userProvider = FutureProvider<User>((ref) async {
  return await fetchUser();
});

// Notifier for complex state
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>(
  (ref) => TodoListNotifier(),
);
```

#### Using Providers in Widgets

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).state++,
      child: Text('Count: $count'),
    );
  }
}
```

### Error Handling

```dart
// Use try-catch for async operations
Future<void> fetchData() async {
  try {
    final data = await apiService.getData();
    // Process data
  } on NetworkException catch (e) {
    // Handle network errors
    logger.error('Network error: ${e.message}');
  } catch (e) {
    // Handle other errors
    logger.error('Unexpected error: $e');
  }
}

// Provide user-friendly error messages
void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

## Making Changes

### Creating a Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/amazing-feature

# Or for bug fixes
git checkout -b fix/bug-description
```

### Branch Naming

- **Features**: `feature/feature-name`
- **Bug fixes**: `fix/bug-description`
- **Docs**: `docs/update-description`
- **Refactoring**: `refactor/what-changed`

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:

```bash
git commit -m "feat(flashcards): add spaced repetition algorithm"
git commit -m "fix(auth): resolve login button not responding"
git commit -m "docs(readme): update installation instructions"
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/flashcards/flashcard_test.dart

# Run integration tests
flutter test integration_test
```

### Writing Tests

#### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('FlashcardService', () {
    late FlashcardService service;
    late MockRepository mockRepo;

    setUp(() {
      mockRepo = MockRepository();
      service = FlashcardService(mockRepo);
    });

    test('calculateNextReview returns correct date', () {
      final result = service.calculateNextReview(
        currentBox: 1,
        easeFactor: 2.5,
      );

      expect(result, isA<DateTime>());
      expect(result.isAfter(DateTime.now()), true);
    });
  });
}
```

#### Widget Tests

```dart
void main() {
  testWidgets('GlassButton displays label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassButton(
            label: 'Test Button',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
  });
}
```

### Test Coverage

We aim for at least 80% code coverage. Check coverage with:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Submitting Changes

### Before Submitting

1. **Run tests**: Ensure all tests pass
   ```bash
   flutter test
   ```

2. **Check linting**: Fix any lint errors
   ```bash
   flutter analyze
   ```

3. **Format code**: Format your code
   ```bash
   flutter format lib test
   ```

4. **Update documentation**: Update relevant docs

### Creating a Pull Request

1. **Push your changes**
   ```bash
   git push origin feature/amazing-feature
   ```

2. **Open a Pull Request** on GitHub

3. **Fill out the PR template** with:
   - Description of changes
   - Related issue number
   - Screenshots (if UI changes)
   - Checklist completion

### PR Template

```markdown
## Description
Brief description of what this PR does.

## Related Issue
Closes #123

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Screenshots (if applicable)
[Add screenshots here]

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where needed
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
- [ ] Any dependent changes have been merged
```

## Review Process

### What to Expect

1. **Automated Checks**: CI/CD runs tests and linting
2. **Code Review**: Maintainers review your code
3. **Feedback**: You may receive change requests
4. **Approval**: Once approved, your PR will be merged

### Responding to Feedback

- Be respectful and professional
- Ask questions if feedback is unclear
- Make requested changes promptly
- Push new commits to the same branch

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase for Flutter](https://firebase.flutter.dev)

## Need Help?

- **Discord**: Join our [Discord community](https://discord.gg/studybuddy)
- **Discussions**: Use [GitHub Discussions](https://github.com/studybuddy/discussions)
- **Email**: Contact us at dev@studybuddy.app

## Recognition

Contributors will be recognized in our README and release notes. Thank you for helping make StudyBuddy better!

---

**Happy Coding! 🚀📚**
