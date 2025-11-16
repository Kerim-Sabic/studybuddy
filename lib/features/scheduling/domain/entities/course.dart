import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Course entity representing a class or subject
class Course extends Equatable {
  final String id;
  final String name;
  final String? code;
  final String? instructor;
  final String? location;
  final Color color;
  final String? description;
  final List<ClassSession> sessions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Course({
    required this.id,
    required this.name,
    this.code,
    this.instructor,
    this.location,
    required this.color,
    this.description,
    this.sessions = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? instructor,
    String? location,
    Color? color,
    String? description,
    List<ClassSession>? sessions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      location: location ?? this.location,
      color: color ?? this.color,
      description: description ?? this.description,
      sessions: sessions ?? this.sessions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        instructor,
        location,
        color,
        description,
        sessions,
        createdAt,
        updatedAt,
      ];
}

/// Class session (recurring schedule for a course)
class ClassSession extends Equatable {
  final String id;
  final String courseId;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? room;
  final String? notes;

  const ClassSession({
    required this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.notes,
  });

  ClassSession copyWith({
    String? id,
    String? courseId,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? room,
    String? notes,
  }) {
    return ClassSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      notes: notes ?? this.notes,
    );
  }

  /// Get the day name
  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  /// Get formatted time range
  String get timeRange {
    final start = startTime.format(null as BuildContext);
    final end = endTime.format(null as BuildContext);
    return '$start - $end';
  }

  @override
  List<Object?> get props => [id, courseId, dayOfWeek, startTime, endTime, room, notes];
}
