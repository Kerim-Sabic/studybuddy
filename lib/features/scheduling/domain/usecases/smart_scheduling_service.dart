import 'package:flutter/material.dart';

import '../entities/assignment.dart';
import '../entities/course.dart';
import '../../tasks/domain/entities/task.dart' as task_entity;
import '../../goals/domain/entities/goal.dart';

/// Smart scheduling service that creates optimized study schedules
class SmartSchedulingService {
  /// Generate a personalized study schedule based on assignments, tasks, and goals
  Future<List<StudyBlock>> generateSmartSchedule({
    required List<Assignment> assignments,
    required List<task_entity.Task> tasks,
    required List<Goal> goals,
    required List<Course> courses,
    required DateTime startDate,
    required DateTime endDate,
    UserPreferences? preferences,
  }) async {
    final studyBlocks = <StudyBlock>[];

    preferences ??= const UserPreferences();

    // 1. Calculate priority scores for each assignment and task
    final prioritizedItems = _prioritizeItems(assignments, tasks, goals);

    // 2. Find available time slots
    final availableSlots = _findAvailableTimeSlots(
      startDate: startDate,
      endDate: endDate,
      courses: courses,
      preferences: preferences,
    );

    // 3. Allocate study blocks using spaced repetition principles
    for (final item in prioritizedItems) {
      final allocatedSlots = _allocateStudyTime(
        item: item,
        availableSlots: availableSlots,
        preferences: preferences,
      );

      studyBlocks.addAll(allocatedSlots);
    }

    // 4. Apply interleaving - mix different subjects
    final interleavedBlocks = _applyInterleaving(studyBlocks);

    // 5. Add breaks using Pomodoro technique
    final blocksWithBreaks = _addBreaks(interleavedBlocks, preferences);

    return blocksWithBreaks;
  }

  /// Prioritize items based on urgency, importance, and difficulty
  List<SchedulableItem> _prioritizeItems(
    List<Assignment> assignments,
    List<task_entity.Task> tasks,
    List<Goal> goals,
  ) {
    final items = <SchedulableItem>[];

    // Convert assignments to schedulable items
    for (final assignment in assignments) {
      if (!assignment.isCompleted) {
        items.add(SchedulableItem(
          id: assignment.id,
          title: assignment.title,
          type: SchedulableItemType.assignment,
          courseId: assignment.courseId,
          dueDate: assignment.dueDate,
          priority: assignment.priority,
          estimatedMinutes: assignment.estimatedMinutes ?? 60,
          urgencyScore: _calculateUrgencyScore(assignment.dueDate),
        ));
      }
    }

    // Convert tasks to schedulable items
    for (final task in tasks) {
      if (!task.isCompleted && task.dueDate != null) {
        items.add(SchedulableItem(
          id: task.id,
          title: task.title,
          type: SchedulableItemType.task,
          courseId: task.courseId,
          dueDate: task.dueDate!,
          priority: task.priority,
          estimatedMinutes: task.estimatedMinutes ?? 30,
          urgencyScore: _calculateUrgencyScore(task.dueDate!),
        ));
      }
    }

    // Sort by combined score: urgency + priority + estimated time
    items.sort((a, b) {
      final scoreA = a.urgencyScore * 0.4 +
                     _priorityToScore(a.priority) * 0.4 +
                     (a.estimatedMinutes / 60) * 0.2;
      final scoreB = b.urgencyScore * 0.4 +
                     _priorityToScore(b.priority) * 0.4 +
                     (b.estimatedMinutes / 60) * 0.2;
      return scoreB.compareTo(scoreA); // Higher score first
    });

    return items;
  }

  /// Calculate urgency score based on time until due date
  double _calculateUrgencyScore(DateTime dueDate) {
    final hoursUntilDue = dueDate.difference(DateTime.now()).inHours;
    if (hoursUntilDue < 0) return 10.0; // Overdue
    if (hoursUntilDue < 24) return 9.0; // Due within 24 hours
    if (hoursUntilDue < 48) return 8.0; // Due within 2 days
    if (hoursUntilDue < 168) return 7.0; // Due within a week
    return 5.0 + (1 / (hoursUntilDue / 168)); // Decay over time
  }

  /// Convert priority enum to numeric score
  double _priorityToScore(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return 10.0;
      case Priority.high:
        return 7.0;
      case Priority.medium:
        return 4.0;
      case Priority.low:
        return 2.0;
    }
  }

  /// Find available time slots excluding class times and sleep
  List<TimeSlot> _findAvailableTimeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required List<Course> courses,
    required UserPreferences preferences,
  }) {
    final slots = <TimeSlot>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate)) {
      // Check each day
      final dayOfWeek = currentDate.weekday;

      // Find class sessions for this day
      final classTimesForDay = <TimeRange>[];
      for (final course in courses) {
        for (final session in course.sessions) {
          if (session.dayOfWeek == dayOfWeek) {
            classTimesForDay.add(TimeRange(
              start: TimeOfDay(
                hour: session.startTime.hour,
                minute: session.startTime.minute,
              ),
              end: TimeOfDay(
                hour: session.endTime.hour,
                minute: session.endTime.minute,
              ),
            ));
          }
        }
      }

      // Create available slots for this day
      final daySlots = _createDaySlotsExcludingBusyTimes(
        date: currentDate,
        busyTimes: classTimesForDay,
        preferences: preferences,
      );

      slots.addAll(daySlots);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return slots;
  }

  /// Create available time slots for a single day
  List<TimeSlot> _createDaySlotsExcludingBusyTimes({
    required DateTime date,
    required List<TimeRange> busyTimes,
    required UserPreferences preferences,
  }) {
    final slots = <TimeSlot>[];

    // Sort busy times
    busyTimes.sort((a, b) => a.start.hour.compareTo(b.start.hour));

    // Create slots between wake time and sleep time
    var currentTime = preferences.wakeTime;

    for (final busyTime in busyTimes) {
      // Add slot before busy time
      if (_timeIsBefore(currentTime, busyTime.start)) {
        final duration = _calculateDuration(currentTime, busyTime.start);
        if (duration >= preferences.minSessionMinutes) {
          slots.add(TimeSlot(
            start: _combineDateAndTime(date, currentTime),
            end: _combineDateAndTime(date, busyTime.start),
            durationMinutes: duration,
          ));
        }
      }
      currentTime = busyTime.end;
    }

    // Add final slot until sleep time
    if (_timeIsBefore(currentTime, preferences.sleepTime)) {
      final duration = _calculateDuration(currentTime, preferences.sleepTime);
      if (duration >= preferences.minSessionMinutes) {
        slots.add(TimeSlot(
          start: _combineDateAndTime(date, currentTime),
          end: _combineDateAndTime(date, preferences.sleepTime),
          durationMinutes: duration,
        ));
      }
    }

    return slots;
  }

  /// Allocate study time for an item across multiple sessions
  List<StudyBlock> _allocateStudyTime({
    required SchedulableItem item,
    required List<TimeSlot> availableSlots,
    required UserPreferences preferences,
  }) {
    final blocks = <StudyBlock>[];
    var remainingMinutes = item.estimatedMinutes;

    // Apply spaced repetition: spread sessions across multiple days
    final sessionDurations = _calculateSpacedSessions(
      totalMinutes: item.estimatedMinutes,
      daysUntilDue: item.dueDate.difference(DateTime.now()).inDays,
      preferences: preferences,
    );

    for (final sessionMinutes in sessionDurations) {
      // Find a suitable slot
      final slot = availableSlots.firstWhere(
        (s) => s.durationMinutes >= sessionMinutes && !s.isAllocated,
        orElse: () => TimeSlot(
          start: DateTime.now(),
          end: DateTime.now(),
          durationMinutes: 0,
        ),
      );

      if (slot.durationMinutes > 0) {
        blocks.add(StudyBlock(
          id: '${item.id}_${blocks.length}',
          itemId: item.id,
          title: item.title,
          courseId: item.courseId,
          start: slot.start,
          durationMinutes: sessionMinutes,
          type: item.type,
        ));

        slot.isAllocated = true;
        remainingMinutes -= sessionMinutes;

        if (remainingMinutes <= 0) break;
      }
    }

    return blocks;
  }

  /// Calculate spaced repetition sessions
  List<int> _calculateSpacedSessions({
    required int totalMinutes,
    required int daysUntilDue,
    required UserPreferences preferences,
  }) {
    final sessions = <int>[];

    if (daysUntilDue <= 1) {
      // Cram if due soon (not ideal, but practical)
      var remaining = totalMinutes;
      while (remaining > 0) {
        final sessionMinutes = remaining > preferences.maxSessionMinutes
            ? preferences.maxSessionMinutes
            : remaining;
        sessions.add(sessionMinutes);
        remaining -= sessionMinutes;
      }
    } else {
      // Spread across days using spacing effect
      final numberOfSessions = (totalMinutes / preferences.idealSessionMinutes).ceil();
      final spacedSessions = numberOfSessions < daysUntilDue
          ? numberOfSessions
          : daysUntilDue;

      final minutesPerSession = totalMinutes ~/ spacedSessions;

      for (var i = 0; i < spacedSessions; i++) {
        sessions.add(minutesPerSession);
      }

      // Add remaining minutes to last session
      final remainder = totalMinutes % spacedSessions;
      if (remainder > 0 && sessions.isNotEmpty) {
        sessions[sessions.length - 1] += remainder;
      }
    }

    return sessions;
  }

  /// Apply interleaving: mix different subjects to improve retention
  List<StudyBlock> _applyInterleaving(List<StudyBlock> blocks) {
    // Group blocks by course
    final blocksByCourse = <String, List<StudyBlock>>{};
    for (final block in blocks) {
      if (block.courseId != null) {
        blocksByCourse.putIfAbsent(block.courseId!, () => []).add(block);
      }
    }

    // Interleave blocks from different courses
    final interleaved = <StudyBlock>[];
    final courseIds = blocksByCourse.keys.toList();

    if (courseIds.isEmpty) return blocks;

    var courseIndex = 0;
    while (blocksByCourse.values.any((list) => list.isNotEmpty)) {
      final courseId = courseIds[courseIndex];
      final courseBlocks = blocksByCourse[courseId]!;

      if (courseBlocks.isNotEmpty) {
        interleaved.add(courseBlocks.removeAt(0));
      }

      courseIndex = (courseIndex + 1) % courseIds.length;
    }

    return interleaved;
  }

  /// Add breaks between study sessions (Pomodoro technique)
  List<StudyBlock> _addBreaks(
    List<StudyBlock> blocks,
    UserPreferences preferences,
  ) {
    final blocksWithBreaks = <StudyBlock>[];

    for (var i = 0; i < blocks.length; i++) {
      blocksWithBreaks.add(blocks[i]);

      // Add break after each block (except the last)
      if (i < blocks.length - 1) {
        final breakMinutes = (i + 1) % 4 == 0
            ? preferences.longBreakMinutes
            : preferences.shortBreakMinutes;

        blocksWithBreaks.add(StudyBlock(
          id: 'break_$i',
          itemId: 'break',
          title: 'Break',
          start: blocks[i].start.add(Duration(minutes: blocks[i].durationMinutes)),
          durationMinutes: breakMinutes,
          type: SchedulableItemType.break,
        ));
      }
    }

    return blocksWithBreaks;
  }

  // Helper methods
  bool _timeIsBefore(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute < b.minute);
  }

  int _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes - startMinutes;
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

/// User preferences for scheduling
class UserPreferences {
  final TimeOfDay wakeTime;
  final TimeOfDay sleepTime;
  final int idealSessionMinutes;
  final int minSessionMinutes;
  final int maxSessionMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final List<int> preferredStudyDays; // 1-7

  const UserPreferences({
    this.wakeTime = const TimeOfDay(hour: 7, minute: 0),
    this.sleepTime = const TimeOfDay(hour: 23, minute: 0),
    this.idealSessionMinutes = 50,
    this.minSessionMinutes = 25,
    this.maxSessionMinutes = 90,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.preferredStudyDays = const [1, 2, 3, 4, 5], // Weekdays
  });
}

/// Item that can be scheduled
class SchedulableItem {
  final String id;
  final String title;
  final SchedulableItemType type;
  final String? courseId;
  final DateTime dueDate;
  final Priority priority;
  final int estimatedMinutes;
  final double urgencyScore;

  SchedulableItem({
    required this.id,
    required this.title,
    required this.type,
    this.courseId,
    required this.dueDate,
    required this.priority,
    required this.estimatedMinutes,
    required this.urgencyScore,
  });
}

enum SchedulableItemType {
  assignment,
  task,
  review,
  break,
}

/// Time slot for scheduling
class TimeSlot {
  final DateTime start;
  final DateTime end;
  final int durationMinutes;
  bool isAllocated;

  TimeSlot({
    required this.start,
    required this.end,
    required this.durationMinutes,
    this.isAllocated = false,
  });
}

/// Study block in the schedule
class StudyBlock {
  final String id;
  final String itemId;
  final String title;
  final String? courseId;
  final DateTime start;
  final int durationMinutes;
  final SchedulableItemType type;

  StudyBlock({
    required this.id,
    required this.itemId,
    required this.title,
    this.courseId,
    required this.start,
    required this.durationMinutes,
    required this.type,
  });

  DateTime get end => start.add(Duration(minutes: durationMinutes));
}

/// Time range helper
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});
}

/// Priority enum (if not already defined)
enum Priority {
  low,
  medium,
  high,
  urgent,
}
