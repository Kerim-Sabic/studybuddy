import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Task entity for general to-do items
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final Priority priority;
  final String? categoryId;
  final String? courseId;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubTask> subtasks;
  final RecurrenceRule? recurrence;
  final List<String> tags;
  final int? estimatedMinutes;
  final int? actualMinutes;
  final String? parentTaskId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = Priority.medium,
    this.categoryId,
    this.courseId,
    this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks = const [],
    this.recurrence,
    this.tags = const [],
    this.estimatedMinutes,
    this.actualMinutes,
    this.parentTaskId,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    String? categoryId,
    String? courseId,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? isCompleted,
    DateTime? completedAt,
    List<SubTask>? subtasks,
    RecurrenceRule? recurrence,
    List<String>? tags,
    int? estimatedMinutes,
    int? actualMinutes,
    String? parentTaskId,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      courseId: courseId ?? this.courseId,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      recurrence: recurrence ?? this.recurrence,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if task is overdue
  bool get isOverdue {
    return dueDate != null && !isCompleted && DateTime.now().isAfter(dueDate!);
  }

  /// Get completion percentage based on subtasks
  double get completionPercentage {
    if (subtasks.isEmpty) {
      return isCompleted ? 100.0 : 0.0;
    }

    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;
    return (completedSubtasks / subtasks.length) * 100;
  }

  /// Check if all subtasks are completed
  bool get areAllSubtasksCompleted {
    if (subtasks.isEmpty) return isCompleted;
    return subtasks.every((s) => s.isCompleted);
  }

  /// Check if task is recurring
  bool get isRecurring => recurrence != null;

  /// Get days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        categoryId,
        courseId,
        dueDate,
        reminderTime,
        isCompleted,
        completedAt,
        subtasks,
        recurrence,
        tags,
        estimatedMinutes,
        actualMinutes,
        parentTaskId,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}

/// Subtask entity
class SubTask extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;

  const SubTask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
  });

  SubTask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
  }) {
    return SubTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, taskId, title, isCompleted, completedAt, sortOrder];
}

/// Recurrence rule for recurring tasks
class RecurrenceRule extends Equatable {
  final RecurrenceFrequency frequency;
  final int interval; // every X days/weeks/months
  final List<int>? daysOfWeek; // 1-7 for weekly
  final int? dayOfMonth; // 1-31 for monthly
  final DateTime? endDate;
  final int? occurrences;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.occurrences,
  });

  RecurrenceRule copyWith({
    RecurrenceFrequency? frequency,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
    int? occurrences,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      endDate: endDate ?? this.endDate,
      occurrences: occurrences ?? this.occurrences,
    );
  }

  /// Get next occurrence date
  DateTime getNextOccurrence(DateTime from) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return from.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return from.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.monthly:
        return DateTime(from.year, from.month + interval, from.day);
      case RecurrenceFrequency.yearly:
        return DateTime(from.year + interval, from.month, from.day);
    }
  }

  /// Check if recurrence has ended
  bool hasEnded(DateTime current, int occurrenceCount) {
    if (endDate != null && current.isAfter(endDate!)) {
      return true;
    }
    if (occurrences != null && occurrenceCount >= occurrences!) {
      return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        frequency,
        interval,
        daysOfWeek,
        dayOfMonth,
        endDate,
        occurrences,
      ];
}

/// Frequency of recurrence
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

extension RecurrenceFrequencyExtension on RecurrenceFrequency {
  String get displayName {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }
}

/// Task category for organization
class TaskCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int color;
  final int sortOrder;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
  });

  TaskCategory copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    int? sortOrder,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, sortOrder];
}
