import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/wellbeing/domain/entities/wellbeing.dart';
import 'package:studybuddy/features/wellbeing/domain/usecases/wellbeing_analyzer_service.dart';

void main() {
  late WellbeingAnalyzerService service;

  setUp(() {
    service = WellbeingAnalyzerService();
  });

  group('Burnout Risk Assessment Tests', () {
    test('Low burnout risk for healthy study patterns', () async {
      final healthyCheckIns = List.generate(
        7,
        (i) => WellbeingCheckIn(
          id: 'check-$i',
          userId: 'user-1',
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          stressLevel: 4,
          energyLevel: 7,
          focusLevel: 7,
          moodScore: 7,
          studyHoursToday: 6,
          tasksCompleted: 5,
          feltOverwhelmed: false,
        ),
      );

      final goodSleep = List.generate(
        7,
        (i) => SleepEntry(
          id: 'sleep-$i',
          userId: 'user-1',
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          bedTime: DateTime.now().subtract(Duration(days: 6 - i, hours: 8)),
          wakeTime: DateTime.now().subtract(Duration(days: 6 - i)),
          qualityScore: 8,
        ),
      );

      final assessment = await service.assessBurnoutRisk(
        userId: 'user-1',
        recentCheckIns: healthyCheckIns,
        recentSleep: goodSleep,
        breaks: [],
        studyHoursThisWeek: 42, // 6 hours/day * 7 days
      );

      expect(assessment.riskLevel, BurnoutRiskLevel.low);
      expect(assessment.riskScore, lessThan(30));
      print('Healthy pattern risk score: ${assessment.riskScore}');
    });

    test('High burnout risk for overworked student', () async {
      final stressedCheckIns = List.generate(
        7,
        (i) => WellbeingCheckIn(
          id: 'check-$i',
          userId: 'user-1',
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          stressLevel: 9,
          energyLevel: 3,
          focusLevel: 4,
          moodScore: 3,
          studyHoursToday: 14,
          tasksCompleted: 3,
          feltOverwhelmed: true,
        ),
      );

      final poorSleep = List.generate(
        7,
        (i) => SleepEntry(
          id: 'sleep-$i',
          userId: 'user-1',
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          bedTime: DateTime.now().subtract(Duration(days: 6 - i, hours: 2)),
          wakeTime: DateTime.now().subtract(Duration(days: 6 - i)),
          qualityScore: 3,
        ),
      );

      final missedBreaks = List.generate(
        10,
        (i) => BreakReminder(
          id: 'break-$i',
          userId: 'user-1',
          scheduledTime: DateTime.now().subtract(Duration(hours: i)),
          type: BreakType.pomodoro,
          durationMinutes: 5,
          wasTaken: false,
        ),
      );

      final assessment = await service.assessBurnoutRisk(
        userId: 'user-1',
        recentCheckIns: stressedCheckIns,
        recentSleep: poorSleep,
        breaks: missedBreaks,
        studyHoursThisWeek: 98, // 14 hours/day * 7 days
      );

      expect(assessment.riskLevel,
          anyOf(BurnoutRiskLevel.high, BurnoutRiskLevel.critical));
      expect(assessment.riskScore, greaterThan(60));
      expect(assessment.recommendations.isNotEmpty, true);
      expect(assessment.consecutiveLongDays, greaterThan(0));

      print('High risk score: ${assessment.riskScore}');
      print('Recommendations: ${assessment.recommendations}');
    });

    test('Critical burnout risk for severe overwork with all-nighters', () async {
      final extremeCheckIns = List.generate(
        7,
        (i) => WellbeingCheckIn(
          id: 'check-$i',
          userId: 'user-1',
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          stressLevel: 10,
          energyLevel: 1,
          focusLevel: 2,
          moodScore: 2,
          studyHoursToday: 16,
          tasksCompleted: 2,
          feltOverwhelmed: true,
        ),
      );

      final allNighters = List.generate(
        3,
        (i) => SleepEntry(
          id: 'sleep-$i',
          userId: 'user-1',
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          bedTime: DateTime.now().subtract(Duration(days: 6 - i, hours: 1)),
          wakeTime: DateTime.now().subtract(Duration(days: 6 - i)),
          qualityScore: 1,
        ),
      );

      final assessment = await service.assessBurnoutRisk(
        userId: 'user-1',
        recentCheckIns: extremeCheckIns,
        recentSleep: allNighters,
        breaks: [],
        studyHoursThisWeek: 112, // 16 hours/day * 7 days
      );

      expect(assessment.riskLevel, BurnoutRiskLevel.critical);
      expect(assessment.riskScore, greaterThan(80));
      expect(assessment.allNighters, 3);
      expect(assessment.recommendations.length, greaterThan(3));

      print('Critical risk score: ${assessment.riskScore}');
    });
  });

  group('Study Load Warning Tests', () {
    test('No warning for reasonable study load', () {
      final warning = service.checkStudyLoad(
        userId: 'user-1',
        scheduledHoursToday: 8,
        scheduledHoursThisWeek: 45,
        todaysCheckIn: null,
      );

      expect(warning, null);
    });

    test('Caution warning for 10+ hour day', () {
      final warning = service.checkStudyLoad(
        userId: 'user-1',
        scheduledHoursToday: 11,
        scheduledHoursThisWeek: 50,
        todaysCheckIn: null,
      );

      expect(warning, isNotNull);
      expect(warning!.level, WarningLevel.caution);
      expect(warning.message.contains('CAUTION'), true);
    });

    test('Warning for 12+ hour day', () {
      final warning = service.checkStudyLoad(
        userId: 'user-1',
        scheduledHoursToday: 13,
        scheduledHoursThisWeek: 60,
        todaysCheckIn: null,
      );

      expect(warning, isNotNull);
      expect(warning!.level, WarningLevel.warning);
      expect(warning.message.contains('WARNING'), true);
    });

    test('Critical warning for 14+ hour day', () {
      final warning = service.checkStudyLoad(
        userId: 'user-1',
        scheduledHoursToday: 15,
        scheduledHoursThisWeek: 70,
        todaysCheckIn: null,
      );

      expect(warning, isNotNull);
      expect(warning!.level, WarningLevel.critical);
      expect(warning.message.contains('CRITICAL'), true);
      expect(warning.scheduledHours, 15);
      expect(warning.recommendedHours, lessThan(15));
    });

    test('Warning when already stressed with moderate study load', () {
      final stressedCheckIn = WellbeingCheckIn(
        id: 'check-1',
        userId: 'user-1',
        date: DateTime.now(),
        stressLevel: 9,
        energyLevel: 3,
        focusLevel: 4,
        moodScore: 3,
        studyHoursToday: 6,
        tasksCompleted: 2,
        feltOverwhelmed: true,
      );

      final warning = service.checkStudyLoad(
        userId: 'user-1',
        scheduledHoursToday: 9,
        scheduledHoursThisWeek: 50,
        todaysCheckIn: stressedCheckIn,
      );

      expect(warning, isNotNull);
      expect(warning!.message.contains('stressed'), true);
    });
  });

  group('Break Recommendation Tests', () {
    test('Recommends appropriate breaks for Pomodoro technique', () {
      final breaks = service.recommendBreakSchedule(
        userId: 'user-1',
        studyStartTime: DateTime(2025, 1, 1, 9, 0),
        plannedStudyMinutes: 120, // 2 hours
      );

      expect(breaks.isNotEmpty, true);

      // Should have short breaks
      final shortBreaks = breaks.where((b) => b.type == BreakType.pomodoro);
      expect(shortBreaks.isNotEmpty, true);

      // Should have at least one long break for 2 hours of study
      final longBreaks = breaks.where((b) => b.type == BreakType.pomodoroLong);
      expect(longBreaks.isNotEmpty, true);

      print('Recommended ${breaks.length} breaks for 120 minutes of study');
    });

    test('Break timing follows Pomodoro intervals', () {
      final startTime = DateTime(2025, 1, 1, 9, 0);
      final breaks = service.recommendBreakSchedule(
        userId: 'user-1',
        studyStartTime: startTime,
        plannedStudyMinutes: 100,
      );

      // First break should be after 25 minutes
      if (breaks.isNotEmpty) {
        final firstBreak = breaks.first;
        final minutesUntilBreak = firstBreak.scheduledTime.difference(startTime).inMinutes;
        expect(minutesUntilBreak, 25);
      }
    });
  });

  group('Focus Efficiency Tests', () {
    test('Perfect focus (100%) with no distractions', () {
      final efficiency = service.calculateFocusEfficiency(
        focusMinutes: 60,
        distractionMinutes: 0,
        distractionEvents: 0,
      );

      expect(efficiency, 100.0);
    });

    test('50% focus with equal focus and distraction time', () {
      final efficiency = service.calculateFocusEfficiency(
        focusMinutes: 30,
        distractionMinutes: 30,
        distractionEvents: 5,
      );

      expect(efficiency, lessThan(50.0)); // Penalty for context switches
      expect(efficiency, greaterThan(0.0));
    });

    test('High distraction count reduces efficiency', () {
      final efficiency1 = service.calculateFocusEfficiency(
        focusMinutes: 50,
        distractionMinutes: 10,
        distractionEvents: 2,
      );

      final efficiency2 = service.calculateFocusEfficiency(
        focusMinutes: 50,
        distractionMinutes: 10,
        distractionEvents: 10,
      );

      expect(efficiency2, lessThan(efficiency1));
      print('Efficiency with 2 distractions: $efficiency1');
      print('Efficiency with 10 distractions: $efficiency2');
    });
  });

  group('Weekly Trend Analysis Tests', () {
    test('Detects improving trend', () {
      final checkIns = [
        // Week starts with low scores
        _createCheckIn(0, stressLevel: 8, energyLevel: 3, focusLevel: 4, moodScore: 4),
        _createCheckIn(1, stressLevel: 7, energyLevel: 4, focusLevel: 5, moodScore: 5),
        _createCheckIn(2, stressLevel: 6, energyLevel: 5, focusLevel: 6, moodScore: 6),
        // Week ends with high scores
        _createCheckIn(3, stressLevel: 4, energyLevel: 7, focusLevel: 8, moodScore: 8),
        _createCheckIn(4, stressLevel: 3, energyLevel: 8, focusLevel: 8, moodScore: 8),
        _createCheckIn(5, stressLevel: 3, energyLevel: 8, focusLevel: 9, moodScore: 9),
      ];

      final trend = service.analyzeWeeklyTrend(checkIns);

      expect(trend.direction, TrendDirection.improving);
      expect(trend.change, greaterThan(5));
      expect(trend.interpretation.contains('improving'), true);

      print('Trend change: ${trend.change}');
    });

    test('Detects declining trend', () {
      final checkIns = [
        // Week starts with high scores
        _createCheckIn(0, stressLevel: 3, energyLevel: 8, focusLevel: 8, moodScore: 8),
        _createCheckIn(1, stressLevel: 4, energyLevel: 7, focusLevel: 7, moodScore: 7),
        _createCheckIn(2, stressLevel: 5, energyLevel: 6, focusLevel: 6, moodScore: 6),
        // Week ends with low scores
        _createCheckIn(3, stressLevel: 7, energyLevel: 4, focusLevel: 4, moodScore: 4),
        _createCheckIn(4, stressLevel: 8, energyLevel: 3, focusLevel: 3, moodScore: 3),
        _createCheckIn(5, stressLevel: 9, energyLevel: 2, focusLevel: 2, moodScore: 2),
      ];

      final trend = service.analyzeWeeklyTrend(checkIns);

      expect(trend.direction, TrendDirection.declining);
      expect(trend.change, lessThan(-5));
      expect(trend.interpretation.contains('declining'), true);
    });
  });
}

WellbeingCheckIn _createCheckIn(int daysAgo, {
  required int stressLevel,
  required int energyLevel,
  required int focusLevel,
  required int moodScore,
}) {
  return WellbeingCheckIn(
    id: 'check-$daysAgo',
    userId: 'user-1',
    date: DateTime.now().subtract(Duration(days: daysAgo)),
    stressLevel: stressLevel,
    energyLevel: energyLevel,
    focusLevel: focusLevel,
    moodScore: moodScore,
    studyHoursToday: 6,
    tasksCompleted: 4,
    feltOverwhelmed: false,
  );
}
