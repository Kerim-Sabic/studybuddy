import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/tasks/domain/entities/task.dart';
import 'package:studybuddy/features/scheduling/domain/usecases/smart_scheduling_service.dart';

void main() {
  group('Task', () {
    test('creates task with required fields', () {
      final task = Task(
        id: 'task-1',
        title: 'Complete homework',
        priority: Priority.medium,
        isCompleted: false,
        subtasks: const [],
      );

      expect(task.id, equals('task-1'));
      expect(task.title, equals('Complete homework'));
      expect(task.priority, equals(Priority.medium));
      expect(task.isCompleted, isFalse);
      expect(task.subtasks, isEmpty);
    });

    test('creates task with optional fields', () {
      final task = Task(
        id: 'task-1',
        title: 'Complete homework',
        description: 'Finish chapters 1-3',
        priority: Priority.high,
        dueDate: DateTime(2024, 12, 31),
        estimatedMinutes: 120,
        actualMinutes: 150,
        courseId: 'course-1',
        categoryId: 'category-1',
        tags: const ['important', 'urgent'],
        isCompleted: false,
        subtasks: const [],
      );

      expect(task.description, equals('Finish chapters 1-3'));
      expect(task.dueDate, equals(DateTime(2024, 12, 31)));
      expect(task.estimatedMinutes, equals(120));
      expect(task.actualMinutes, equals(150));
      expect(task.courseId, equals('course-1'));
      expect(task.categoryId, equals('category-1'));
      expect(task.tags, equals(['important', 'urgent']));
    });

    group('completionPercentage', () {
      test('returns 100 when task is completed with no subtasks', () {
        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: true,
          subtasks: const [],
        );

        expect(task.completionPercentage, equals(100.0));
      });

      test('returns 0 when task is not completed with no subtasks', () {
        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: const [],
        );

        expect(task.completionPercentage, equals(0.0));
      });

      test('calculates percentage based on completed subtasks', () {
        const subtasks = [
          SubTask(id: '1', taskId: 'task-1', title: 'Subtask 1', isCompleted: true),
          SubTask(id: '2', taskId: 'task-1', title: 'Subtask 2', isCompleted: true),
          SubTask(id: '3', taskId: 'task-1', title: 'Subtask 3', isCompleted: false),
          SubTask(id: '4', taskId: 'task-1', title: 'Subtask 4', isCompleted: false),
        ];

        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: subtasks,
        );

        expect(task.completionPercentage, equals(50.0)); // 2 out of 4
      });

      test('returns 100 when all subtasks are completed', () {
        const subtasks = [
          SubTask(id: '1', taskId: 'task-1', title: 'Subtask 1', isCompleted: true),
          SubTask(id: '2', taskId: 'task-1', title: 'Subtask 2', isCompleted: true),
        ];

        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: subtasks,
        );

        expect(task.completionPercentage, equals(100.0));
      });

      test('returns 0 when no subtasks are completed', () {
        const subtasks = [
          SubTask(id: '1', taskId: 'task-1', title: 'Subtask 1', isCompleted: false),
          SubTask(id: '2', taskId: 'task-1', title: 'Subtask 2', isCompleted: false),
        ];

        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: subtasks,
        );

        expect(task.completionPercentage, equals(0.0));
      });
    });

    group('areAllSubtasksCompleted', () {
      test('returns true when all subtasks are completed', () {
        const subtasks = [
          SubTask(id: '1', taskId: 'task-1', title: 'Subtask 1', isCompleted: true),
          SubTask(id: '2', taskId: 'task-1', title: 'Subtask 2', isCompleted: true),
        ];

        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: subtasks,
        );

        expect(task.areAllSubtasksCompleted, isTrue);
      });

      test('returns false when some subtasks are not completed', () {
        const subtasks = [
          SubTask(id: '1', taskId: 'task-1', title: 'Subtask 1', isCompleted: true),
          SubTask(id: '2', taskId: 'task-1', title: 'Subtask 2', isCompleted: false),
        ];

        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: subtasks,
        );

        expect(task.areAllSubtasksCompleted, isFalse);
      });

      test('returns true when there are no subtasks', () {
        final task = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: const [],
        );

        expect(task.areAllSubtasksCompleted, isTrue);
      });
    });

    group('equality', () {
      test('tasks with same properties are equal', () {
        final task1 = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: const [],
        );

        final task2 = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: const [],
        );

        expect(task1, equals(task2));
      });

      test('tasks with different ids are not equal', () {
        final task1 = Task(
          id: 'task-1',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: const [],
        );

        final task2 = Task(
          id: 'task-2',
          title: 'Task',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: const [],
        );

        expect(task1, isNot(equals(task2)));
      });
    });
  });

  group('SubTask', () {
    test('creates subtask with required fields', () {
      const subtask = SubTask(
        id: 'subtask-1',
        taskId: 'task-1',
        title: 'Subtask',
        isCompleted: false,
      );

      expect(subtask.id, equals('subtask-1'));
      expect(subtask.taskId, equals('task-1'));
      expect(subtask.title, equals('Subtask'));
      expect(subtask.isCompleted, isFalse);
    });

    test('equality works correctly', () {
      const subtask1 = SubTask(
        id: 'subtask-1',
        taskId: 'task-1',
        title: 'Subtask',
        isCompleted: false,
      );

      const subtask2 = SubTask(
        id: 'subtask-1',
        taskId: 'task-1',
        title: 'Subtask',
        isCompleted: false,
      );

      expect(subtask1, equals(subtask2));
    });
  });

  group('RecurrenceRule', () {
    test('creates daily recurrence rule', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      );

      expect(rule.frequency, equals(RecurrenceFrequency.daily));
      expect(rule.interval, equals(1));
    });

    test('creates weekly recurrence rule with specific days', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        daysOfWeek: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );

      expect(rule.frequency, equals(RecurrenceFrequency.weekly));
      expect(rule.daysOfWeek, equals([DateTime.monday, DateTime.wednesday, DateTime.friday]));
    });

    test('creates monthly recurrence rule', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        interval: 2,
      );

      expect(rule.frequency, equals(RecurrenceFrequency.monthly));
      expect(rule.interval, equals(2));
    });

    test('creates recurrence rule with end date', () {
      final endDate = DateTime(2025, 12, 31);
      final rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: endDate,
      );

      expect(rule.endDate, equals(endDate));
    });

    group('getNextOccurrence', () {
      test('calculates next occurrence for daily recurrence', () {
        const rule = RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        );

        final from = DateTime(2024, 1, 1);
        final next = rule.getNextOccurrence(from);

        expect(next, equals(DateTime(2024, 1, 2)));
      });

      test('calculates next occurrence for weekly recurrence', () {
        const rule = RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
        );

        final from = DateTime(2024, 1, 1); // Monday
        final next = rule.getNextOccurrence(from);

        expect(next, equals(DateTime(2024, 1, 8))); // Next Monday
      });

      test('calculates next occurrence for monthly recurrence', () {
        const rule = RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          interval: 1,
        );

        final from = DateTime(2024, 1, 15);
        final next = rule.getNextOccurrence(from);

        expect(next, equals(DateTime(2024, 2, 15)));
      });

      test('calculates next occurrence for yearly recurrence', () {
        const rule = RecurrenceRule(
          frequency: RecurrenceFrequency.yearly,
          interval: 1,
        );

        final from = DateTime(2024, 6, 15);
        final next = rule.getNextOccurrence(from);

        expect(next, equals(DateTime(2025, 6, 15)));
      });

      test('respects interval for daily recurrence', () {
        const rule = RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 3,
        );

        final from = DateTime(2024, 1, 1);
        final next = rule.getNextOccurrence(from);

        expect(next, equals(DateTime(2024, 1, 4)));
      });

      test('respects interval for weekly recurrence', () {
        const rule = RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 2,
        );

        final from = DateTime(2024, 1, 1); // Monday
        final next = rule.getNextOccurrence(from);

        expect(next, equals(DateTime(2024, 1, 15))); // Two weeks later
      });
    });

    test('equality works correctly', () {
      const rule1 = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      );

      const rule2 = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      );

      expect(rule1, equals(rule2));
    });
  });

  group('TaskCategory', () {
    test('creates category with required fields', () {
      const category = TaskCategory(
        id: 'category-1',
        name: 'Work',
        color: 0xFF667EEA,
      );

      expect(category.id, equals('category-1'));
      expect(category.name, equals('Work'));
      expect(category.color, equals(0xFF667EEA));
    });

    test('creates category with optional icon', () {
      const category = TaskCategory(
        id: 'category-1',
        name: 'Work',
        color: 0xFF667EEA,
        icon: 'work',
      );

      expect(category.icon, equals('work'));
    });

    test('equality works correctly', () {
      const category1 = TaskCategory(
        id: 'category-1',
        name: 'Work',
        color: 0xFF667EEA,
      );

      const category2 = TaskCategory(
        id: 'category-1',
        name: 'Work',
        color: 0xFF667EEA,
      );

      expect(category1, equals(category2));
    });
  });

  group('RecurrenceFrequency', () {
    test('has all expected frequencies', () {
      expect(RecurrenceFrequency.values.length, equals(4));
      expect(RecurrenceFrequency.values, contains(RecurrenceFrequency.daily));
      expect(RecurrenceFrequency.values, contains(RecurrenceFrequency.weekly));
      expect(RecurrenceFrequency.values, contains(RecurrenceFrequency.monthly));
      expect(RecurrenceFrequency.values, contains(RecurrenceFrequency.yearly));
    });
  });
}
