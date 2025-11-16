import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/scheduling/domain/entities/assignment.dart';
import 'package:studybuddy/features/scheduling/domain/entities/course.dart';
import 'package:studybuddy/features/scheduling/domain/usecases/smart_scheduling_service.dart';
import 'package:studybuddy/features/tasks/domain/entities/task.dart';
import 'package:studybuddy/features/goals/domain/entities/goal.dart';
import 'package:flutter/material.dart';

void main() {
  group('Performance Tests - Large Datasets', () {
    late SmartSchedulingService service;

    setUp(() {
      service = SmartSchedulingService();
    });

    test('Handles 100 assignments efficiently', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      final assignments = List.generate(
        100,
        (i) => Assignment(
          id: 'assign-$i',
          courseId: 'course-${i % 5}', // 5 different courses
          title: 'Assignment $i',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(Duration(days: i % 30)),
          priority: Priority.values[i % 4],
          estimatedMinutes: 60 + (i % 120),
          isCompleted: false,
        ),
      );

      // Act
      final schedule = await service.generateSmartSchedule(
        assignments: assignments,
        tasks: [],
        goals: [],
        courses: [],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      stopwatch.stop();

      // Assert
      expect(schedule.isNotEmpty, true);

      final elapsedMs = stopwatch.elapsedMilliseconds;
      print('✅ Generated schedule for 100 assignments in ${elapsedMs}ms');

      // Should complete within 2 seconds
      expect(elapsedMs, lessThan(2000),
          reason: 'Scheduling 100 assignments should take less than 2 seconds');

      // Should create study blocks for all assignments
      final assignmentBlocks = schedule.where(
        (b) => b.type == SchedulableItemType.assignment,
      );
      expect(assignmentBlocks.length, greaterThan(50),
          reason: 'Should schedule most assignments');
    });

    test('Handles 1000 tasks efficiently', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      final tasks = List.generate(
        1000,
        (i) => Task(
          id: 'task-$i',
          title: 'Task $i',
          priority: Priority.values[i % 4],
          dueDate: DateTime.now().add(Duration(hours: i)),
          estimatedMinutes: 30,
          isCompleted: i % 10 == 0, // 10% completed
          subtasks: [],
        ),
      );

      stopwatch.stop();

      final createTime = stopwatch.elapsedMilliseconds;
      print('✅ Created 1000 tasks in ${createTime}ms');

      // Creating 1000 tasks should be nearly instant
      expect(createTime, lessThan(100),
          reason: 'Creating 1000 tasks should be very fast');

      // Test filtering performance
      stopwatch.reset();
      stopwatch.start();

      final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();

      stopwatch.stop();
      final filterTime = stopwatch.elapsedMilliseconds;

      print('✅ Filtered 1000 tasks in ${filterTime}ms');
      expect(filterTime, lessThan(50),
          reason: 'Filtering should be very fast');

      expect(incompleteTasks.length, equals(900));
    });

    test('Calculates completion percentage for 500 tasks with subtasks', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      final tasks = List.generate(
        500,
        (i) => Task(
          id: 'task-$i',
          title: 'Task $i',
          priority: Priority.medium,
          isCompleted: false,
          subtasks: List.generate(
            10,
            (j) => SubTask(
              id: 'subtask-$i-$j',
              taskId: 'task-$i',
              title: 'Subtask $j',
              isCompleted: j < 5, // 50% completed
            ),
          ),
        ),
      );

      // Act
      final percentages = tasks.map((t) => t.completionPercentage).toList();

      stopwatch.stop();

      // Assert
      final elapsedMs = stopwatch.elapsedMilliseconds;
      print('✅ Calculated completion for 500 tasks (5000 subtasks) in ${elapsedMs}ms');

      expect(elapsedMs, lessThan(100),
          reason: 'Completion calculation should be fast even with many subtasks');

      expect(percentages.every((p) => p == 50.0), true,
          reason: 'All tasks should be 50% complete');
    });

    test('Goal progress tracking scales to 200 goals', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      final goals = List.generate(
        200,
        (i) => Goal(
          id: 'goal-$i',
          title: 'Goal $i',
          type: GoalType.values[i % 3],
          category: GoalCategory.values[i % 8],
          startDate: DateTime.now().subtract(Duration(days: i % 30)),
          targetDate: DateTime.now().add(Duration(days: 30 - (i % 30))),
          targetValue: 100,
          currentValue: i.toDouble() % 100,
          unit: 'points',
          milestones: [],
          isCompleted: false,
        ),
      );

      // Act - Calculate all metrics
      final onTrackGoals = goals.where((g) => g.isOnTrack).toList();
      final completionPercentages = goals.map((g) => g.completionPercentage).toList();
      final recommendedProgress = goals.map((g) => g.recommendedDailyProgress).toList();

      stopwatch.stop();

      // Assert
      final elapsedMs = stopwatch.elapsedMilliseconds;
      print('✅ Processed 200 goals with all calculations in ${elapsedMs}ms');

      expect(elapsedMs, lessThan(100),
          reason: 'Goal calculations should be fast for 200 goals');

      expect(onTrackGoals.length, greaterThan(0),
          reason: 'Some goals should be on track');
      expect(completionPercentages.length, equals(200));
      expect(recommendedProgress.length, equals(200));
    });

    test('Assignment sorting and filtering with 500 items', () async {
      // Arrange
      final assignments = List.generate(
        500,
        (i) => Assignment(
          id: 'assign-$i',
          courseId: 'course-${i % 10}',
          title: 'Assignment $i',
          type: AssignmentType.values[i % 8],
          dueDate: DateTime.now().add(Duration(days: i % 60)),
          priority: Priority.values[i % 4],
          estimatedMinutes: 60,
          isCompleted: i % 5 == 0, // 20% completed
        ),
      );

      // Test 1: Filter by overdue
      var stopwatch = Stopwatch()..start();
      final overdue = assignments.where((a) => a.isOverdue).toList();
      stopwatch.stop();

      print('✅ Filtered 500 assignments for overdue in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      // Test 2: Filter by due soon
      stopwatch = Stopwatch()..start();
      final dueSoon = assignments.where((a) => a.isDueSoon).toList();
      stopwatch.stop();

      print('✅ Filtered 500 assignments for due soon in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      // Test 3: Sort by due date
      stopwatch = Stopwatch()..start();
      final sorted = [...assignments]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      stopwatch.stop();

      print('✅ Sorted 500 assignments by due date in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(sorted.length, equals(500));

      // Test 4: Group by course
      stopwatch = Stopwatch()..start();
      final grouped = <String, List<Assignment>>{};
      for (final assignment in assignments) {
        grouped.putIfAbsent(assignment.courseId, () => []).add(assignment);
      }
      stopwatch.stop();

      print('✅ Grouped 500 assignments by course in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(grouped.length, equals(10)); // 10 different courses
    });

    test('Course session conflict detection with 50 courses', () async {
      // Arrange
      final courses = List.generate(
        50,
        (i) => Course(
          id: 'course-$i',
          name: 'Course $i',
          color: Color(0xFF000000 + i * 1000),
          sessions: List.generate(
            3, // MWF
            (j) => ClassSession(
              id: 'session-$i-$j',
              courseId: 'course-$i',
              dayOfWeek: [DateTime.monday, DateTime.wednesday, DateTime.friday][j],
              startTime: TimeOfDay(hour: 9 + (i % 6), minute: 0),
              endTime: TimeOfDay(hour: 10 + (i % 6), minute: 30),
            ),
          ),
        ),
      );

      // Test: Find conflicts
      final stopwatch = Stopwatch()..start();

      final conflicts = <String>[];
      for (int i = 0; i < courses.length; i++) {
        for (int j = i + 1; j < courses.length; j++) {
          final course1 = courses[i];
          final course2 = courses[j];

          for (final session1 in course1.sessions) {
            for (final session2 in course2.sessions) {
              if (session1.dayOfWeek == session2.dayOfWeek) {
                // Check time overlap
                final start1 = session1.startTime.hour * 60 + session1.startTime.minute;
                final end1 = session1.endTime.hour * 60 + session1.endTime.minute;
                final start2 = session2.startTime.hour * 60 + session2.startTime.minute;
                final end2 = session2.endTime.hour * 60 + session2.endTime.minute;

                if (!(end1 <= start2 || start1 >= end2)) {
                  conflicts.add('${course1.id} conflicts with ${course2.id}');
                }
              }
            }
          }
        }
      }

      stopwatch.stop();

      print('✅ Detected conflicts in 50 courses (150 sessions) in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      print('   Found ${conflicts.length} conflicts');
    });

    test('Memory efficiency: Create and destroy 10,000 tasks', () async {
      // This tests garbage collection and memory management
      final stopwatch = Stopwatch()..start();

      for (int batch = 0; batch < 10; batch++) {
        final tasks = List.generate(
          1000,
          (i) => Task(
            id: 'task-${batch * 1000 + i}',
            title: 'Task ${batch * 1000 + i}',
            priority: Priority.medium,
            isCompleted: false,
            subtasks: [],
          ),
        );

        // Process tasks
        final _ = tasks.where((t) => !t.isCompleted).length;

        // Let garbage collection happen
        await Future.delayed(Duration.zero);
      }

      stopwatch.stop();

      print('✅ Created and processed 10,000 tasks in batches in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Stress test: Full schedule with maximum data', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      final courses = List.generate(
        20,
        (i) => Course(
          id: 'course-$i',
          name: 'Course $i',
          color: Color(0xFF667EEA + i * 1000),
          sessions: [
            ClassSession(
              id: 'session-$i',
              courseId: 'course-$i',
              dayOfWeek: DateTime.monday + (i % 5),
              startTime: TimeOfDay(hour: 9 + (i % 6), minute: 0),
              endTime: TimeOfDay(hour: 10 + (i % 6), minute: 30),
            ),
          ],
        ),
      );

      final assignments = List.generate(
        200,
        (i) => Assignment(
          id: 'assign-$i',
          courseId: 'course-${i % 20}',
          title: 'Assignment $i',
          type: AssignmentType.values[i % 8],
          dueDate: DateTime.now().add(Duration(days: i % 60)),
          priority: Priority.values[i % 4],
          estimatedMinutes: 60 + (i % 120),
          isCompleted: false,
        ),
      );

      final tasks = List.generate(
        200,
        (i) => Task(
          id: 'task-$i',
          title: 'Task $i',
          priority: Priority.values[i % 4],
          dueDate: DateTime.now().add(Duration(days: i % 30)),
          estimatedMinutes: 30,
          isCompleted: false,
          subtasks: [],
        ),
      );

      final goals = List.generate(
        50,
        (i) => Goal(
          id: 'goal-$i',
          title: 'Goal $i',
          type: GoalType.shortTerm,
          category: GoalCategory.studyTime,
          startDate: DateTime.now(),
          targetDate: DateTime.now().add(const Duration(days: 30)),
          targetValue: 100,
          currentValue: 0,
          unit: 'hours',
          milestones: [],
          isCompleted: false,
        ),
      );

      // Act
      final schedule = await service.generateSmartSchedule(
        assignments: assignments,
        tasks: tasks,
        goals: goals,
        courses: courses,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 60)),
      );

      stopwatch.stop();

      // Assert
      final elapsedMs = stopwatch.elapsedMilliseconds;
      print('✅ STRESS TEST COMPLETE:');
      print('   - 20 courses with sessions');
      print('   - 200 assignments');
      print('   - 200 tasks');
      print('   - 50 goals');
      print('   - Generated schedule in ${elapsedMs}ms');

      expect(elapsedMs, lessThan(5000),
          reason: 'Full schedule with maximum data should complete within 5 seconds');

      expect(schedule.isNotEmpty, true);

      // Count study blocks
      final studyBlocks = schedule.where(
        (b) => b.type != SchedulableItemType.break,
      ).length;
      final breakBlocks = schedule.where(
        (b) => b.type == SchedulableItemType.break,
      ).length;

      print('   - Study blocks: $studyBlocks');
      print('   - Break blocks: $breakBlocks');

      expect(studyBlocks, greaterThan(100),
          reason: 'Should generate many study blocks');
      expect(breakBlocks, greaterThan(0),
          reason: 'Should include breaks');
    });
  });
}
