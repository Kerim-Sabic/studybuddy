import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/scheduling/domain/entities/assignment.dart';
import 'package:studybuddy/features/scheduling/domain/entities/course.dart';
import 'package:studybuddy/features/scheduling/domain/usecases/smart_scheduling_service.dart';
import 'package:studybuddy/features/tasks/domain/entities/task.dart';
import 'package:studybuddy/features/goals/domain/entities/goal.dart';

void main() {
  group('SmartSchedulingService', () {
    late SmartSchedulingService service;

    setUp(() {
      service = SmartSchedulingService();
    });

    group('Schedule Generation', () {
      test('generates empty schedule when no items provided', () async {
        final schedule = await service.generateSmartSchedule(
          assignments: [],
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        expect(schedule, isEmpty, reason: 'Should return empty schedule with no items');
      });

      test('generates schedule with study blocks for assignments', () async {
        final assignments = [
          Assignment(
            id: 'assign1',
            courseId: 'course1',
            title: 'Math Homework',
            type: AssignmentType.homework,
            dueDate: DateTime.now().add(const Duration(days: 3)),
            priority: Priority.high,
            estimatedMinutes: 120,
            isCompleted: false,
          ),
        ];

        final schedule = await service.generateSmartSchedule(
          assignments: assignments,
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        expect(schedule.isNotEmpty, true, reason: 'Should generate study blocks');

        // Check that assignment is included in schedule
        final assignmentBlocks = schedule.where(
          (b) => b.itemId == 'assign1' && b.type == SchedulableItemType.assignment,
        );
        expect(assignmentBlocks.isNotEmpty, true,
            reason: 'Schedule should include assignment blocks');
      });

      test('generates schedule with study blocks for tasks', () async {
        final tasks = [
          Task(
            id: 'task1',
            title: 'Review Notes',
            priority: Priority.medium,
            dueDate: DateTime.now().add(const Duration(days: 2)),
            estimatedMinutes: 60,
            isCompleted: false,
            subtasks: const [],
          ),
        ];

        final schedule = await service.generateSmartSchedule(
          assignments: [],
          tasks: tasks,
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        expect(schedule.isNotEmpty, true);

        final taskBlocks = schedule.where(
          (b) => b.itemId == 'task1' && b.type == SchedulableItemType.task,
        );
        expect(taskBlocks.isNotEmpty, true,
            reason: 'Schedule should include task blocks');
      });

      test('prioritizes urgent items over normal items', () async {
        final urgentAssignment = Assignment(
          id: 'urgent',
          courseId: 'course1',
          title: 'Urgent Exam',
          type: AssignmentType.exam,
          dueDate: DateTime.now().add(const Duration(hours: 12)),
          priority: Priority.urgent,
          estimatedMinutes: 90,
          isCompleted: false,
        );

        final normalAssignment = Assignment(
          id: 'normal',
          courseId: 'course2',
          title: 'Normal Homework',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: Priority.medium,
          estimatedMinutes: 60,
          isCompleted: false,
        );

        final schedule = await service.generateSmartSchedule(
          assignments: [normalAssignment, urgentAssignment],
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        final urgentBlocks = schedule.where(
          (b) => b.itemId == 'urgent' && b.type == SchedulableItemType.assignment,
        ).toList();
        final normalBlocks = schedule.where(
          (b) => b.itemId == 'normal' && b.type == SchedulableItemType.assignment,
        ).toList();

        if (urgentBlocks.isNotEmpty && normalBlocks.isNotEmpty) {
          expect(
            urgentBlocks.first.start.isBefore(normalBlocks.first.start),
            true,
            reason: 'Urgent items should be scheduled before normal items',
          );
        }
      });

      test('includes breaks in schedule', () async {
        final assignments = List.generate(
          4,
          (i) => Assignment(
            id: 'assign$i',
            courseId: 'course$i',
            title: 'Assignment $i',
            type: AssignmentType.homework,
            dueDate: DateTime.now().add(Duration(days: i + 2)),
            priority: Priority.medium,
            estimatedMinutes: 50,
            isCompleted: false,
          ),
        );

        final schedule = await service.generateSmartSchedule(
          assignments: assignments,
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        final breakBlocks = schedule.where((b) => b.type == SchedulableItemType.break);
        expect(breakBlocks.isNotEmpty, true,
            reason: 'Schedule should include breaks');
      });

      test('avoids scheduling during class sessions', () async {
        final courses = [
          Course(
            id: 'course1',
            name: 'Math 101',
            color: const Color(0xFF667EEA),
            sessions: [
              ClassSession(
                id: 'session1',
                courseId: 'course1',
                dayOfWeek: DateTime.monday,
                startTime: const TimeOfDay(hour: 10, minute: 0),
                endTime: const TimeOfDay(hour: 11, minute: 30),
              ),
            ],
          ),
        ];

        final assignments = [
          Assignment(
            id: 'assign1',
            courseId: 'course1',
            title: 'Math Homework',
            type: AssignmentType.homework,
            dueDate: DateTime.now().add(const Duration(days: 7)),
            priority: Priority.medium,
            estimatedMinutes: 120,
            isCompleted: false,
          ),
        ];

        final now = DateTime.now();
        // Find next Monday
        final monday = now.add(Duration(days: (DateTime.monday - now.weekday) % 7));

        final schedule = await service.generateSmartSchedule(
          assignments: assignments,
          tasks: [],
          goals: [],
          courses: courses,
          startDate: monday,
          endDate: monday.add(const Duration(days: 7)),
        );

        // Filter to Monday's study blocks only
        final mondayBlocks = schedule.where((b) {
          return b.start.weekday == DateTime.monday &&
              b.type != SchedulableItemType.break;
        });

        for (final block in mondayBlocks) {
          final blockStartMinutes = block.start.hour * 60 + block.start.minute;
          final blockEndMinutes = block.end.hour * 60 + block.end.minute;
          final classStart = 10 * 60;
          final classEnd = 11 * 60 + 30;

          // Check for overlap
          final overlaps = !(blockEndMinutes <= classStart || blockStartMinutes >= classEnd);
          expect(overlaps, false,
              reason: 'Study blocks should not overlap with class sessions');
        }
      });

      test('respects user preferences for study times', () async {
        final preferences = UserPreferences(
          wakeTime: const TimeOfDay(hour: 8, minute: 0),
          sleepTime: const TimeOfDay(hour: 22, minute: 0),
          shortBreakMinutes: 10,
          longBreakMinutes: 30,
        );

        final assignments = [
          Assignment(
            id: 'assign1',
            courseId: 'course1',
            title: 'Homework',
            type: AssignmentType.homework,
            dueDate: DateTime.now().add(const Duration(days: 3)),
            priority: Priority.medium,
            estimatedMinutes: 90,
            isCompleted: false,
          ),
        ];

        final schedule = await service.generateSmartSchedule(
          assignments: assignments,
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          preferences: preferences,
        );

        for (final block in schedule) {
          final startHour = block.start.hour;
          final endHour = block.end.hour;

          expect(startHour, greaterThanOrEqualTo(8),
              reason: 'Study blocks should not start before wake time');
          expect(endHour, lessThanOrEqualTo(22),
              reason: 'Study blocks should end before sleep time');
        }

        // Check for custom break durations
        final breakBlocks = schedule.where((b) => b.type == SchedulableItemType.break);
        if (breakBlocks.isNotEmpty) {
          for (final breakBlock in breakBlocks) {
            expect(
              [10, 30],
              contains(breakBlock.durationMinutes),
              reason: 'Breaks should use custom duration from preferences',
            );
          }
        }
      });

      test('applies interleaving when multiple courses present', () async {
        final assignments = [
          Assignment(
            id: 'math1',
            courseId: 'math',
            title: 'Math Problem Set',
            type: AssignmentType.homework,
            dueDate: DateTime.now().add(const Duration(days: 5)),
            priority: Priority.high,
            estimatedMinutes: 120,
            isCompleted: false,
          ),
          Assignment(
            id: 'physics1',
            courseId: 'physics',
            title: 'Physics Lab Report',
            type: AssignmentType.lab,
            dueDate: DateTime.now().add(const Duration(days: 5)),
            priority: Priority.high,
            estimatedMinutes: 120,
            isCompleted: false,
          ),
        ];

        final schedule = await service.generateSmartSchedule(
          assignments: assignments,
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        final studyBlocks = schedule.where(
          (b) => b.type == SchedulableItemType.assignment,
        ).toList();

        // Check that subjects are interleaved (not all math blocks then all physics blocks)
        if (studyBlocks.length >= 4) {
          final courseSequence = studyBlocks.take(4).map((b) => b.courseId).toList();
          final allSameCourse = courseSequence.every((id) => id == courseSequence.first);

          expect(allSameCourse, false,
              reason: 'Different subjects should be interleaved');
        }
      });

      test('splits long assignments into multiple sessions', () async {
        final longAssignment = Assignment(
          id: 'long1',
          courseId: 'course1',
          title: 'Long Project',
          type: AssignmentType.project,
          dueDate: DateTime.now().add(const Duration(days: 14)),
          priority: Priority.high,
          estimatedMinutes: 600, // 10 hours
          isCompleted: false,
        );

        final schedule = await service.generateSmartSchedule(
          assignments: [longAssignment],
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)),
        );

        final projectBlocks = schedule.where(
          (b) => b.itemId == 'long1' && b.type == SchedulableItemType.assignment,
        ).toList();

        expect(projectBlocks.length, greaterThan(1),
            reason: 'Long assignments should be split into multiple sessions');

        // Check that sessions are spread across days (spaced repetition)
        if (projectBlocks.length >= 2) {
          final firstDay = projectBlocks.first.start.day;
          final secondDay = projectBlocks[1].start.day;

          expect(firstDay, isNot(equals(secondDay)),
              reason: 'Sessions should be spaced across different days');
        }
      });

      test('skips completed items', () async {
        final completedAssignment = Assignment(
          id: 'completed',
          courseId: 'course1',
          title: 'Completed Homework',
          type: AssignmentType.homework,
          dueDate: DateTime.now().add(const Duration(days: 3)),
          priority: Priority.high,
          estimatedMinutes: 90,
          isCompleted: true,
        );

        final schedule = await service.generateSmartSchedule(
          assignments: [completedAssignment],
          tasks: [],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        final completedBlocks = schedule.where((b) => b.itemId == 'completed');
        expect(completedBlocks, isEmpty,
            reason: 'Completed items should not be scheduled');
      });

      test('handles tasks without due dates by skipping them', () async {
        final taskWithoutDueDate = Task(
          id: 'task1',
          title: 'No Due Date Task',
          priority: Priority.low,
          dueDate: null,
          estimatedMinutes: 30,
          isCompleted: false,
          subtasks: const [],
        );

        final schedule = await service.generateSmartSchedule(
          assignments: [],
          tasks: [taskWithoutDueDate],
          goals: [],
          courses: [],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        );

        final taskBlocks = schedule.where((b) => b.itemId == 'task1');
        expect(taskBlocks, isEmpty,
            reason: 'Tasks without due dates should not be scheduled');
      });
    });

    group('UserPreferences', () {
      test('uses default values when not specified', () {
        const preferences = UserPreferences();

        expect(preferences.wakeTime, equals(const TimeOfDay(hour: 7, minute: 0)));
        expect(preferences.sleepTime, equals(const TimeOfDay(hour: 23, minute: 0)));
        expect(preferences.idealSessionMinutes, equals(50));
        expect(preferences.minSessionMinutes, equals(25));
        expect(preferences.maxSessionMinutes, equals(90));
        expect(preferences.shortBreakMinutes, equals(5));
        expect(preferences.longBreakMinutes, equals(15));
        expect(preferences.preferredStudyDays, equals([1, 2, 3, 4, 5]));
      });

      test('accepts custom values', () {
        const preferences = UserPreferences(
          wakeTime: TimeOfDay(hour: 6, minute: 30),
          sleepTime: TimeOfDay(hour: 22, minute: 30),
          idealSessionMinutes: 60,
          shortBreakMinutes: 10,
          longBreakMinutes: 20,
        );

        expect(preferences.wakeTime, equals(const TimeOfDay(hour: 6, minute: 30)));
        expect(preferences.sleepTime, equals(const TimeOfDay(hour: 22, minute: 30)));
        expect(preferences.idealSessionMinutes, equals(60));
        expect(preferences.shortBreakMinutes, equals(10));
        expect(preferences.longBreakMinutes, equals(20));
      });
    });

    group('StudyBlock', () {
      test('calculates end time correctly', () {
        final start = DateTime(2024, 1, 15, 10, 0);
        final block = StudyBlock(
          id: 'block1',
          itemId: 'item1',
          title: 'Study Session',
          start: start,
          durationMinutes: 60,
          type: SchedulableItemType.assignment,
        );

        final expectedEnd = DateTime(2024, 1, 15, 11, 0);
        expect(block.end, equals(expectedEnd));
      });

      test('handles midnight boundary correctly', () {
        final start = DateTime(2024, 1, 15, 23, 30);
        final block = StudyBlock(
          id: 'block1',
          itemId: 'item1',
          title: 'Late Study Session',
          start: start,
          durationMinutes: 60,
        );

        final expectedEnd = DateTime(2024, 1, 16, 0, 30);
        expect(block.end, equals(expectedEnd));
      });
    });
  });
}
