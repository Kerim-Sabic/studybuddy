import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/data/database/app_database.dart';
import 'package:studybuddy/features/scheduling/presentation/providers/course_provider.dart';
import 'package:studybuddy/features/scheduling/domain/entities/course.dart';
import 'package:flutter/material.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([AppDatabase])
import 'course_provider_test.mocks.dart';

void main() {
  group('CourseProvider', () {
    late MockAppDatabase mockDatabase;
    late ProviderContainer container;

    setUp(() {
      mockDatabase = MockAppDatabase();

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('coursesProvider', () {
      test('emits list of courses when database returns data', () async {
        // Arrange
        final mockCourses = [
          CoursesCompanion.insert(
            id: const Value('course-1'),
            name: 'Math 101',
            color: Colors.blue.value,
            createdAt: DateTime.now(),
          ),
          CoursesCompanion.insert(
            id: const Value('course-2'),
            name: 'Physics 201',
            color: Colors.green.value,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockDatabase.watchAllCourses()).thenAnswer(
          (_) => Stream.value(mockCourses.map((c) => Course(
            id: c.id.value,
            name: c.name.value,
            color: Color(c.color.value),
            sessions: const [],
          )).toList()),
        );

        // Act
        final asyncValue = container.read(coursesProvider);

        // Assert
        asyncValue.when(
          data: (courses) {
            expect(courses.length, equals(2));
            expect(courses[0].name, equals('Math 101'));
            expect(courses[1].name, equals('Physics 201'));
          },
          loading: () => fail('Should not be loading'),
          error: (error, stack) => fail('Should not have error: $error'),
        );
      });

      test('emits empty list when database has no courses', () async {
        // Arrange
        when(mockDatabase.watchAllCourses()).thenAnswer(
          (_) => Stream.value([]),
        );

        // Act
        final asyncValue = container.read(coursesProvider);

        // Assert
        asyncValue.when(
          data: (courses) => expect(courses, isEmpty),
          loading: () => fail('Should not be loading'),
          error: (error, stack) => fail('Should not have error'),
        );
      });

      test('emits error when database throws exception', () async {
        // Arrange
        when(mockDatabase.watchAllCourses()).thenAnswer(
          (_) => Stream.error(Exception('Database error')),
        );

        // Act
        final asyncValue = container.read(coursesProvider);

        // Assert
        asyncValue.when(
          data: (courses) => fail('Should not have data'),
          loading: () => fail('Should not be loading'),
          error: (error, stack) {
            expect(error, isA<Exception>());
            expect(error.toString(), contains('Database error'));
          },
        );
      });

      test('updates when new course is added', () async {
        // Arrange
        final initialCourses = <Course>[];
        final updatedCourses = [
          Course(
            id: 'course-1',
            name: 'New Course',
            color: Colors.blue,
            sessions: const [],
          ),
        ];

        final controller = StreamController<List<Course>>();
        when(mockDatabase.watchAllCourses()).thenAnswer(
          (_) => controller.stream,
        );

        // Act
        controller.add(initialCourses);
        await Future.delayed(Duration.zero);

        var asyncValue = container.read(coursesProvider);
        asyncValue.when(
          data: (courses) => expect(courses, isEmpty),
          loading: () => fail('Should not be loading'),
          error: (error, stack) => fail('Should not have error'),
        );

        controller.add(updatedCourses);
        await Future.delayed(Duration.zero);

        asyncValue = container.read(coursesProvider);
        asyncValue.when(
          data: (courses) {
            expect(courses.length, equals(1));
            expect(courses[0].name, equals('New Course'));
          },
          loading: () => fail('Should not be loading'),
          error: (error, stack) => fail('Should not have error'),
        );

        // Cleanup
        await controller.close();
      });
    });

    group('courseByIdProvider', () {
      test('returns course when it exists', () async {
        // Arrange
        final course = Course(
          id: 'course-1',
          name: 'Math 101',
          color: Colors.blue,
          sessions: const [],
        );

        when(mockDatabase.getCourseById('course-1')).thenAnswer(
          (_) async => course,
        );

        // Act
        final asyncValue = await container.read(
          courseByIdProvider('course-1').future,
        );

        // Assert
        expect(asyncValue?.id, equals('course-1'));
        expect(asyncValue?.name, equals('Math 101'));
      });

      test('returns null when course does not exist', () async {
        // Arrange
        when(mockDatabase.getCourseById('non-existent')).thenAnswer(
          (_) async => null,
        );

        // Act
        final asyncValue = await container.read(
          courseByIdProvider('non-existent').future,
        );

        // Assert
        expect(asyncValue, isNull);
      });

      test('throws error when database fails', () async {
        // Arrange
        when(mockDatabase.getCourseById('course-1')).thenThrow(
          Exception('Database error'),
        );

        // Act & Assert
        expect(
          () => container.read(courseByIdProvider('course-1').future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('CourseController', () {
      late CourseController controller;

      setUp(() {
        controller = CourseController(mockDatabase);
      });

      group('createCourse', () {
        test('creates course successfully', () async {
          // Arrange
          when(mockDatabase.insertCourse(any)).thenAnswer((_) async => 1);

          // Act
          final courseId = await controller.createCourse(
            name: 'Math 101',
            color: Colors.blue,
            code: 'MATH-101',
            instructor: 'Dr. Smith',
            location: 'Room 204',
          );

          // Assert
          expect(courseId, isNotNull);
          verify(mockDatabase.insertCourse(any)).called(1);
        });

        test('throws exception when database insert fails', () async {
          // Arrange
          when(mockDatabase.insertCourse(any)).thenThrow(
            Exception('Insert failed'),
          );

          // Act & Assert
          expect(
            () => controller.createCourse(
              name: 'Math 101',
              color: Colors.blue,
            ),
            throwsA(isA<Exception>()),
          );
        });

        test('validates required fields', () async {
          // Arrange & Act & Assert
          expect(
            () => controller.createCourse(
              name: '',
              color: Colors.blue,
            ),
            throwsA(isA<ArgumentError>()),
          );
        });
      });

      group('updateCourse', () {
        test('updates course successfully', () async {
          // Arrange
          when(mockDatabase.updateCourse(any)).thenAnswer((_) async => 1);

          // Act
          await controller.updateCourse(
            id: 'course-1',
            name: 'Updated Math 101',
            color: Colors.red,
          );

          // Assert
          verify(mockDatabase.updateCourse(any)).called(1);
        });

        test('throws exception when course does not exist', () async {
          // Arrange
          when(mockDatabase.updateCourse(any)).thenAnswer((_) async => 0);

          // Act & Assert
          expect(
            () => controller.updateCourse(
              id: 'non-existent',
              name: 'Updated',
              color: Colors.blue,
            ),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('deleteCourse', () {
        test('deletes course successfully', () async {
          // Arrange
          when(mockDatabase.deleteCourse('course-1')).thenAnswer((_) async => 1);

          // Act
          await controller.deleteCourse('course-1');

          // Assert
          verify(mockDatabase.deleteCourse('course-1')).called(1);
        });

        test('throws exception when course does not exist', () async {
          // Arrange
          when(mockDatabase.deleteCourse('non-existent')).thenAnswer(
            (_) async => 0,
          );

          // Act & Assert
          expect(
            () => controller.deleteCourse('non-existent'),
            throwsA(isA<Exception>()),
          );
        });

        test('deletes cascade (sessions, assignments)', () async {
          // Arrange
          when(mockDatabase.deleteCourse('course-1')).thenAnswer((_) async => 1);
          when(mockDatabase.deleteSessionsByCourseId('course-1')).thenAnswer(
            (_) async => 3,
          );
          when(mockDatabase.deleteAssignmentsByCourseId('course-1')).thenAnswer(
            (_) async => 5,
          );

          // Act
          await controller.deleteCourse('course-1');

          // Assert
          verify(mockDatabase.deleteCourse('course-1')).called(1);
          verify(mockDatabase.deleteSessionsByCourseId('course-1')).called(1);
          verify(mockDatabase.deleteAssignmentsByCourseId('course-1')).called(1);
        });
      });

      group('addClassSession', () {
        test('adds session successfully', () async {
          // Arrange
          when(mockDatabase.insertClassSession(any)).thenAnswer((_) async => 1);

          // Act
          final sessionId = await controller.addClassSession(
            courseId: 'course-1',
            dayOfWeek: DateTime.monday,
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endTime: const TimeOfDay(hour: 11, minute: 30),
            location: 'Room 204',
          );

          // Assert
          expect(sessionId, isNotNull);
          verify(mockDatabase.insertClassSession(any)).called(1);
        });

        test('validates start time before end time', () async {
          // Arrange & Act & Assert
          expect(
            () => controller.addClassSession(
              courseId: 'course-1',
              dayOfWeek: DateTime.monday,
              startTime: const TimeOfDay(hour: 12, minute: 0),
              endTime: const TimeOfDay(hour: 10, minute: 0),
            ),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('validates day of week range (1-7)', () async {
          // Arrange & Act & Assert
          expect(
            () => controller.addClassSession(
              courseId: 'course-1',
              dayOfWeek: 0,
              startTime: const TimeOfDay(hour: 10, minute: 0),
              endTime: const TimeOfDay(hour: 11, minute: 0),
            ),
            throwsA(isA<ArgumentError>()),
          );

          expect(
            () => controller.addClassSession(
              courseId: 'course-1',
              dayOfWeek: 8,
              startTime: const TimeOfDay(hour: 10, minute: 0),
              endTime: const TimeOfDay(hour: 11, minute: 0),
            ),
            throwsA(isA<ArgumentError>()),
          );
        });
      });

      group('removeClassSession', () {
        test('removes session successfully', () async {
          // Arrange
          when(mockDatabase.deleteClassSession('session-1')).thenAnswer(
            (_) async => 1,
          );

          // Act
          await controller.removeClassSession('session-1');

          // Assert
          verify(mockDatabase.deleteClassSession('session-1')).called(1);
        });
      });
    });
  });
}
