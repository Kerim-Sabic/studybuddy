import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/scheduling/domain/entities/course.dart';

void main() {
  group('Course', () {
    test('creates course with required fields', () {
      const course = Course(
        id: 'course-1',
        name: 'Mathematics 101',
        color: Color(0xFF667EEA),
        sessions: [],
      );

      expect(course.id, equals('course-1'));
      expect(course.name, equals('Mathematics 101'));
      expect(course.color, equals(const Color(0xFF667EEA)));
      expect(course.sessions, isEmpty);
    });

    test('creates course with optional fields', () {
      const course = Course(
        id: 'course-1',
        name: 'Mathematics 101',
        code: 'MATH-101',
        instructor: 'Dr. Smith',
        location: 'Room 204',
        color: Color(0xFF667EEA),
        sessions: [],
      );

      expect(course.code, equals('MATH-101'));
      expect(course.instructor, equals('Dr. Smith'));
      expect(course.location, equals('Room 204'));
    });

    test('creates course with class sessions', () {
      const session1 = ClassSession(
        id: 'session-1',
        courseId: 'course-1',
        dayOfWeek: DateTime.monday,
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 30),
      );

      const session2 = ClassSession(
        id: 'session-2',
        courseId: 'course-1',
        dayOfWeek: DateTime.wednesday,
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 30),
      );

      const course = Course(
        id: 'course-1',
        name: 'Mathematics 101',
        color: Color(0xFF667EEA),
        sessions: [session1, session2],
      );

      expect(course.sessions.length, equals(2));
      expect(course.sessions[0].dayOfWeek, equals(DateTime.monday));
      expect(course.sessions[1].dayOfWeek, equals(DateTime.wednesday));
    });

    group('equality', () {
      test('courses with same id are equal', () {
        const course1 = Course(
          id: 'same-id',
          name: 'Course 1',
          color: Color(0xFF667EEA),
          sessions: [],
        );

        const course2 = Course(
          id: 'same-id',
          name: 'Course 1',
          color: Color(0xFF667EEA),
          sessions: [],
        );

        expect(course1, equals(course2));
      });

      test('courses with different ids are not equal', () {
        const course1 = Course(
          id: 'id-1',
          name: 'Course',
          color: Color(0xFF667EEA),
          sessions: [],
        );

        const course2 = Course(
          id: 'id-2',
          name: 'Course',
          color: Color(0xFF667EEA),
          sessions: [],
        );

        expect(course1, isNot(equals(course2)));
      });
    });
  });

  group('ClassSession', () {
    test('creates class session with required fields', () {
      const session = ClassSession(
        id: 'session-1',
        courseId: 'course-1',
        dayOfWeek: DateTime.monday,
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 30),
      );

      expect(session.id, equals('session-1'));
      expect(session.courseId, equals('course-1'));
      expect(session.dayOfWeek, equals(DateTime.monday));
      expect(session.startTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(session.endTime, equals(const TimeOfDay(hour: 11, minute: 30)));
    });

    group('dayName', () {
      test('returns Monday for dayOfWeek 1', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Monday'));
      });

      test('returns Tuesday for dayOfWeek 2', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.tuesday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Tuesday'));
      });

      test('returns Wednesday for dayOfWeek 3', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.wednesday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Wednesday'));
      });

      test('returns Thursday for dayOfWeek 4', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.thursday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Thursday'));
      });

      test('returns Friday for dayOfWeek 5', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.friday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Friday'));
      });

      test('returns Saturday for dayOfWeek 6', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.saturday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Saturday'));
      });

      test('returns Sunday for dayOfWeek 7', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.sunday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.dayName, equals('Sunday'));
      });
    });

    group('durationMinutes', () {
      test('calculates duration correctly for same hour', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 10, minute: 50),
        );

        expect(session.durationMinutes, equals(50));
      });

      test('calculates duration correctly across hours', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.durationMinutes, equals(90));
      });

      test('calculates duration correctly for multi-hour sessions', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 9, minute: 30),
          endTime: TimeOfDay(hour: 12, minute: 0),
        );

        expect(session.durationMinutes, equals(150));
      });

      test('handles 15-minute increments correctly', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 15),
          endTime: TimeOfDay(hour: 11, minute: 45),
        );

        expect(session.durationMinutes, equals(90));
      });
    });

    group('timeRange', () {
      test('formats time range correctly for morning classes', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session.timeRange, equals('10:00 - 11:30'));
      });

      test('formats time range correctly with single-digit hours', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 9, minute: 0),
          endTime: TimeOfDay(hour: 10, minute: 30),
        );

        expect(session.timeRange, equals('09:00 - 10:30'));
      });

      test('formats time range correctly with non-zero minutes', () {
        const session = ClassSession(
          id: 'session-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 15),
          endTime: TimeOfDay(hour: 11, minute: 45),
        );

        expect(session.timeRange, equals('10:15 - 11:45'));
      });
    });

    group('equality', () {
      test('sessions with same id are equal', () {
        const session1 = ClassSession(
          id: 'same-id',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        const session2 = ClassSession(
          id: 'same-id',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session1, equals(session2));
      });

      test('sessions with different ids are not equal', () {
        const session1 = ClassSession(
          id: 'id-1',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        const session2 = ClassSession(
          id: 'id-2',
          courseId: 'course-1',
          dayOfWeek: DateTime.monday,
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 30),
        );

        expect(session1, isNot(equals(session2)));
      });
    });
  });
}
