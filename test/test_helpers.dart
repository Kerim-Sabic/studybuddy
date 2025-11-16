import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up the test environment
/// Call this before running tests that need Flutter bindings
void setupTestEnvironment() {
  // Ensure Flutter bindings are initialized for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Prevent debugPrint from cluttering test output
  debugPrint = (String? message, {int? wrapWidth}) {};
}

/// Resets the test environment after tests
void teardownTestEnvironment() {
  // Reset debugPrint to default
  debugPrint = debugPrintSynchronously;
}
