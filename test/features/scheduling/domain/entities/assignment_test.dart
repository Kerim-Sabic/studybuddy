import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/scheduling/domain/entities/assignment.dart';
import 'package:studybuddy/features/scheduling/domain/usecases/smart_scheduling_service.dart';

void main() {
  group('Assignment', () {
    test('creates assignment with required fields', () {
      final assignment = Assignment(
        id: 'test-id',
        courseId: 'course-1',
        title: 'Math Homework',
        type: AssignmentType.homework,
        dueDate: DateTime(2024, 12, 31),
        priority: Priority.medium,
        isCompleted: false,
      );

      expect(assignment.id, equals('test-id'));
      expect(assignment.courseId, equals('course-1'));
      expect(assignment.title, equals('Math Homework'));
      expect(assignment.type, equals(AssignmentType.homework));
      expect(assignment.isCompleted, isFalse);
    });

    group('isOverdue', () {
      test('returns true when past due date and not completed', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Overdue Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.isOverdue, isTrue);
      });

      test('returns false when past due date but completed', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Completed Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          priority: Priority.medium,
          isCompleted: true,
        );

        expect(assignment.isOverdue, isFalse);
      });

      test('returns false when before due date', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Future Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.isOverdue, isFalse);
      });
    });

    group('daysUntilDue', () {
      test('returns positive days for future due dates', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.daysUntilDue, equals(5));
      });

      test('returns negative days for past due dates', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().subtract(const Duration(days: 3)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.daysUntilDue, equals(-3));
      });
    });

    group('hoursUntilDue', () {
      test('returns correct hours for future due dates', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(hours: 12)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.hoursUntilDue, equals(12));
      });
    });

    group('isDueSoon', () {
      test('returns true when due within 24 hours and not completed', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(hours: 12)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.isDueSoon, isTrue);
      });

      test('returns false when due beyond 24 hours', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(hours: 30)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.isDueSoon, isFalse);
      });

      test('returns false when completed even if due soon', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(hours: 12)),
          priority: Priority.medium,
          isCompleted: true,
        );

        expect(assignment.isDueSoon, isFalse);
      });
    });

    group('completionPercentage', () {
      test('returns correct percentage when grade is available', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: Priority.medium,
          isCompleted: true,
          grade: 85,
          maxGrade: 100,
        );

        expect(assignment.completionPercentage, equals(85.0));
      });

      test('returns null when grade is not available', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment.completionPercentage, isNull);
      });

      test('handles different max grades correctly', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: Priority.medium,
          isCompleted: true,
          grade: 45,
          maxGrade: 50,
        );

        expect(assignment.completionPercentage, equals(90.0));
      });

      test('returns null when maxGrade is 0', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: Priority.medium,
          isCompleted: true,
          grade: 45,
          maxGrade: 0,
        );

        expect(assignment.completionPercentage, isNull);
      });
    });

    group('equality', () {
      test('assignments with same id are equal', () {
        final assignment1 = Assignment(
          id: 'same-id',
          courseId: 'course1',
          title: 'Assignment 1',
          type: AssignmentType.homework,
          dueDate: DateTime(2024, 12, 31),
          priority: Priority.medium,
          isCompleted: false,
        );

        final assignment2 = Assignment(
          id: 'same-id',
          courseId: 'course1',
          title: 'Assignment 1',
          type: AssignmentType.homework,
          dueDate: DateTime(2024, 12, 31),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment1, equals(assignment2));
      });

      test('assignments with different ids are not equal', () {
        final assignment1 = Assignment(
          id: 'id-1',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime(2024, 12, 31),
          priority: Priority.medium,
          isCompleted: false,
        );

        final assignment2 = Assignment(
          id: 'id-2',
          courseId: 'course1',
          title: 'Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime(2024, 12, 31),
          priority: Priority.medium,
          isCompleted: false,
        );

        expect(assignment1, isNot(equals(assignment2)));
      });
    });

    group('AssignmentType', () {
      test('has all expected types', () {
        expect(AssignmentType.values.length, equals(8));
        expect(AssignmentType.values, contains(AssignmentType.homework));
        expect(AssignmentType.values, contains(AssignmentType.project));
        expect(AssignmentType.values, contains(AssignmentType.exam));
        expect(AssignmentType.values, contains(AssignmentType.quiz));
        expect(AssignmentType.values, contains(AssignmentType.lab));
        expect(AssignmentType.values, contains(AssignmentType.reading));
        expect(AssignmentType.values, contains(AssignmentType.presentation));
        expect(AssignmentType.values, contains(AssignmentType.other));
      });
    });

    group('Priority', () {
      test('has all priority levels', () {
        expect(Priority.values.length, equals(4));
        expect(Priority.values, contains(Priority.low));
        expect(Priority.values, contains(Priority.medium));
        expect(Priority.values, contains(Priority.high));
        expect(Priority.values, contains(Priority.urgent));
      });
    });

    group('optional fields', () {
      test('accepts null for optional fields', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Minimal Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now(),
          priority: Priority.medium,
          isCompleted: false,
          description: null,
          estimatedMinutes: null,
          actualMinutes: null,
          grade: null,
          maxGrade: null,
        );

        expect(assignment.description, isNull);
        expect(assignment.estimatedMinutes, isNull);
        expect(assignment.actualMinutes, isNull);
        expect(assignment.grade, isNull);
        expect(assignment.maxGrade, isNull);
      });

      test('stores optional fields when provided', () {
        final assignment = Assignment(
          id: '1',
          courseId: 'course1',
          title: 'Full Assignment',
          type: AssignmentType.homework,
          dueDate: DateTime.now(),
          priority: Priority.medium,
          isCompleted: false,
          description: 'Complete chapters 1-3',
          estimatedMinutes: 120,
          actualMinutes: 150,
          grade: 95,
          maxGrade: 100,
        );

        expect(assignment.description, equals('Complete chapters 1-3'));
        expect(assignment.estimatedMinutes, equals(120));
        expect(assignment.actualMinutes, equals(150));
        expect(assignment.grade, equals(95));
        expect(assignment.maxGrade, equals(100));
      });
    });
  });
}
