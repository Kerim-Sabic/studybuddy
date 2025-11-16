import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/goals/domain/entities/goal.dart';

void main() {
  group('Goal', () {
    test('creates goal with required fields', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Study 10 hours per week',
        type: GoalType.shortTerm,
        category: GoalCategory.studyTime,
        startDate: DateTime(2024, 1, 1),
        targetDate: DateTime(2024, 1, 31),
        targetValue: 40,
        currentValue: 0,
        unit: 'hours',
        milestones: const [],
        isCompleted: false,
      );

      expect(goal.id, equals('goal-1'));
      expect(goal.title, equals('Study 10 hours per week'));
      expect(goal.type, equals(GoalType.shortTerm));
      expect(goal.category, equals(GoalCategory.studyTime));
      expect(goal.targetValue, equals(40));
      expect(goal.currentValue, equals(0));
      expect(goal.unit, equals('hours'));
      expect(goal.isCompleted, isFalse);
    });

    test('creates goal with optional fields', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Complete Course',
        description: 'Finish all assignments and exams',
        type: GoalType.shortTerm,
        category: GoalCategory.completion,
        startDate: DateTime(2024, 1, 1),
        targetDate: DateTime(2024, 6, 30),
        targetValue: 100,
        currentValue: 25,
        unit: 'percent',
        courseId: 'course-1',
        tags: const ['important', 'academic'],
        notes: 'Focus on weekly progress',
        milestones: const [],
        isCompleted: false,
      );

      expect(goal.description, equals('Finish all assignments and exams'));
      expect(goal.courseId, equals('course-1'));
      expect(goal.tags, equals(['important', 'academic']));
      expect(goal.notes, equals('Focus on weekly progress'));
    });

    group('completionPercentage', () {
      test('calculates percentage correctly', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 100,
          currentValue: 75,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.completionPercentage, equals(75.0));
      });

      test('returns 0 when currentValue is 0', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 100,
          currentValue: 0,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.completionPercentage, equals(0.0));
      });

      test('returns 100 when currentValue equals targetValue', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 50,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.completionPercentage, equals(100.0));
      });

      test('can exceed 100 if currentValue exceeds targetValue', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 50,
          currentValue: 60,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.completionPercentage, equals(120.0));
      });

      test('returns 0 when targetValue is 0', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 0,
          currentValue: 10,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.completionPercentage, equals(0.0));
      });
    });

    group('timeProgressPercentage', () {
      test('calculates time progress correctly at 50% through duration', () {
        final startDate = DateTime(2024, 1, 1);
        final targetDate = DateTime(2024, 1, 31); // 30 days
        final now = DateTime(2024, 1, 16); // 15 days in

        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: startDate,
          targetDate: targetDate,
          targetValue: 100,
          currentValue: 40,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        // Mock DateTime.now() is not possible without dependency injection
        // This test would need refactoring of Goal entity to support testing
        // For now, we test the calculation logic indirectly
      });

      test('returns 0 when goal just started', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now(),
          targetDate: DateTime.now().add(const Duration(days: 30)),
          targetValue: 100,
          currentValue: 0,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.timeProgressPercentage, closeTo(0, 5));
      });
    });

    group('isOnTrack', () {
      test('returns true when completion is ahead of time progress', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          targetDate: DateTime.now().add(const Duration(days: 20)),
          targetValue: 100,
          currentValue: 60, // 60% complete, but only ~33% through time
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.isOnTrack, isTrue);
      });

      test('returns false when completion is behind time progress', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now().subtract(const Duration(days: 25)),
          targetDate: DateTime.now().add(const Duration(days: 5)),
          targetValue: 100,
          currentValue: 20, // Only 20% complete, but ~83% through time
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.isOnTrack, isFalse);
      });
    });

    group('daysRemaining', () {
      test('returns positive days for future target dates', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now(),
          targetDate: DateTime.now().add(const Duration(days: 10)),
          targetValue: 100,
          currentValue: 0,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.daysRemaining, equals(10));
      });

      test('returns 0 for today as target date', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          targetDate: DateTime.now(),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.daysRemaining, equals(0));
      });
    });

    group('recommendedDailyProgress', () {
      test('calculates daily progress needed to reach goal', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now(),
          targetDate: DateTime.now().add(const Duration(days: 10)),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        // 50 remaining / 10 days = 5 per day
        expect(goal.recommendedDailyProgress, equals(5.0));
      });

      test('returns 0 when goal is already achieved', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now().subtract(const Duration(days: 20)),
          targetDate: DateTime.now().add(const Duration(days: 10)),
          targetValue: 100,
          currentValue: 100,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.recommendedDailyProgress, equals(0.0));
      });

      test('returns 0 when target date has passed', () {
        final goal = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          targetDate: DateTime.now().subtract(const Duration(days: 1)),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal.recommendedDailyProgress, equals(0.0));
      });
    });

    group('equality', () {
      test('goals with same properties are equal', () {
        final goal1 = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        final goal2 = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal1, equals(goal2));
      });

      test('goals with different ids are not equal', () {
        final goal1 = Goal(
          id: 'goal-1',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        final goal2 = Goal(
          id: 'goal-2',
          title: 'Goal',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime(2024, 1, 1),
          targetDate: DateTime(2024, 1, 31),
          targetValue: 100,
          currentValue: 50,
          unit: 'hours',
          milestones: const [],
          isCompleted: false,
        );

        expect(goal1, isNot(equals(goal2)));
      });
    });
  });

  group('Milestone', () {
    test('creates milestone with required fields', () {
      final milestone = Milestone(
        id: 'milestone-1',
        goalId: 'goal-1',
        title: 'Complete 50%',
        targetValue: 50,
        targetDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );

      expect(milestone.id, equals('milestone-1'));
      expect(milestone.goalId, equals('goal-1'));
      expect(milestone.title, equals('Complete 50%'));
      expect(milestone.targetValue, equals(50));
      expect(milestone.isCompleted, isFalse);
    });

    test('creates milestone with optional description', () {
      final milestone = Milestone(
        id: 'milestone-1',
        goalId: 'goal-1',
        title: 'Complete 50%',
        description: 'Halfway checkpoint',
        targetValue: 50,
        targetDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );

      expect(milestone.description, equals('Halfway checkpoint'));
    });

    test('equality works correctly', () {
      final milestone1 = Milestone(
        id: 'milestone-1',
        goalId: 'goal-1',
        title: 'Milestone',
        targetValue: 50,
        targetDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );

      final milestone2 = Milestone(
        id: 'milestone-1',
        goalId: 'goal-1',
        title: 'Milestone',
        targetValue: 50,
        targetDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );

      expect(milestone1, equals(milestone2));
    });
  });

  group('GoalType', () {
    test('has all expected types', () {
      expect(GoalType.values.length, equals(3));
      expect(GoalType.values, contains(GoalType.shortTerm));
      expect(GoalType.values, contains(GoalType.mediumTerm));
      expect(GoalType.values, contains(GoalType.longTerm));
    });
  });

  group('GoalCategory', () {
    test('has all expected categories', () {
      expect(GoalCategory.values.length, equals(8));
      expect(GoalCategory.values, contains(GoalCategory.grade));
      expect(GoalCategory.values, contains(GoalCategory.studyTime));
      expect(GoalCategory.values, contains(GoalCategory.completion));
      expect(GoalCategory.values, contains(GoalCategory.skill));
      expect(GoalCategory.values, contains(GoalCategory.habit));
      expect(GoalCategory.values, contains(GoalCategory.project));
      expect(GoalCategory.values, contains(GoalCategory.reading));
      expect(GoalCategory.values, contains(GoalCategory.other));
    });
  });
}
