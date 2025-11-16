import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Assignment entity representing homework, projects, exams
class Assignment extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final AssignmentType type;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? estimatedMinutes;
  final int? actualMinutes;
  final List<String> attachments;
  final List<String> tags;
  final double? grade;
  final double? maxGrade;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.type,
    required this.dueDate,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.estimatedMinutes,
    this.actualMinutes,
    this.attachments = const [],
    this.tags = const [],
    this.grade,
    this.maxGrade,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Assignment copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    AssignmentType? type,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    int? estimatedMinutes,
    int? actualMinutes,
    List<String>? attachments,
    List<String>? tags,
    double? grade,
    double? maxGrade,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if assignment is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(dueDate);
  }

  /// Get days until due
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get hours until due
  int get hoursUntilDue {
    return dueDate.difference(DateTime.now()).inHours;
  }

  /// Check if due soon (within 24 hours)
  bool get isDueSoon {
    return !isCompleted && hoursUntilDue <= 24 && hoursUntilDue >= 0;
  }

  /// Get completion percentage (if has grade)
  double? get completionPercentage {
    if (grade != null && maxGrade != null && maxGrade! > 0) {
      return (grade! / maxGrade!) * 100;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        type,
        dueDate,
        priority,
        isCompleted,
        completedAt,
        estimatedMinutes,
        actualMinutes,
        attachments,
        tags,
        grade,
        maxGrade,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Type of assignment
enum AssignmentType {
  homework,
  project,
  exam,
  quiz,
  lab,
  reading,
  presentation,
  other,
}

extension AssignmentTypeExtension on AssignmentType {
  String get displayName {
    switch (this) {
      case AssignmentType.homework:
        return 'Homework';
      case AssignmentType.project:
        return 'Project';
      case AssignmentType.exam:
        return 'Exam';
      case AssignmentType.quiz:
        return 'Quiz';
      case AssignmentType.lab:
        return 'Lab';
      case AssignmentType.reading:
        return 'Reading';
      case AssignmentType.presentation:
        return 'Presentation';
      case AssignmentType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case AssignmentType.homework:
        return '📝';
      case AssignmentType.project:
        return '🚀';
      case AssignmentType.exam:
        return '📋';
      case AssignmentType.quiz:
        return '❓';
      case AssignmentType.lab:
        return '🔬';
      case AssignmentType.reading:
        return '📖';
      case AssignmentType.presentation:
        return '🎤';
      case AssignmentType.other:
        return '📌';
    }
  }
}
