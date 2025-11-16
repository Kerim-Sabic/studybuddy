import 'package:studybuddy/features/wellbeing/domain/entities/wellbeing.dart';

/// Service for analyzing student well-being and detecting burnout risk
class WellbeingAnalyzerService {
  /// Assess burnout risk based on recent well-being data
  Future<BurnoutAssessment> assessBurnoutRisk({
    required String userId,
    required List<WellbeingCheckIn> recentCheckIns,
    required List<SleepEntry> recentSleep,
    required List<BreakReminder> breaks,
    required int studyHoursThisWeek,
  }) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Filter to last 7 days
    final weekCheckIns = recentCheckIns
        .where((c) => c.date.isAfter(sevenDaysAgo))
        .toList();
    final weekSleep = recentSleep
        .where((s) => s.date.isAfter(sevenDaysAgo))
        .toList();

    // Calculate contributing factors
    final consecutiveLongDays = _calculateConsecutiveLongDays(weekCheckIns);
    final missedBreaks = _calculateMissedBreaks(breaks);
    final allNighters = _calculateAllNighters(weekSleep);
    final avgStressLevel = _calculateAverageStress(weekCheckIns);
    final avgSleepHours = _calculateAverageSleep(weekSleep);

    // Calculate risk score (0-100)
    final riskScore = _calculateRiskScore(
      consecutiveLongDays: consecutiveLongDays,
      missedBreaks: missedBreaks,
      allNighters: allNighters,
      avgStressLevel: avgStressLevel,
      avgSleepHours: avgSleepHours,
      studyHoursThisWeek: studyHoursThisWeek,
    );

    // Determine risk level
    final riskLevel = _determineRiskLevel(riskScore);

    // Generate recommendations
    final recommendations = BurnoutAssessment.generateRecommendations(
      BurnoutAssessment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        assessedAt: now,
        riskLevel: riskLevel,
        riskScore: riskScore,
        consecutiveLongDays: consecutiveLongDays,
        missedBreaks: missedBreaks,
        allNighters: allNighters,
        averageStressLevel: avgStressLevel,
        averageSleepHours: avgSleepHours,
      ),
    );

    return BurnoutAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      assessedAt: now,
      riskLevel: riskLevel,
      riskScore: riskScore,
      consecutiveLongDays: consecutiveLongDays,
      missedBreaks: missedBreaks,
      allNighters: allNighters,
      averageStressLevel: avgStressLevel,
      averageSleepHours: avgSleepHours,
      recommendations: recommendations,
    );
  }

  /// Calculate consecutive days with 10+ study hours
  int _calculateConsecutiveLongDays(List<WellbeingCheckIn> checkIns) {
    if (checkIns.isEmpty) return 0;

    // Sort by date (newest first)
    checkIns.sort((a, b) => b.date.compareTo(a.date));

    int consecutive = 0;
    for (final checkIn in checkIns) {
      if (checkIn.studyHoursToday >= 10) {
        consecutive++;
      } else {
        break; // Stop at first non-long day
      }
    }

    return consecutive;
  }

  /// Calculate missed breaks in last 7 days
  int _calculateMissedBreaks(List<BreakReminder> breaks) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return breaks.where((b) {
      return b.scheduledTime.isAfter(sevenDaysAgo) &&
          b.scheduledTime.isBefore(DateTime.now()) &&
          !b.wasTaken;
    }).length;
  }

  /// Count all-nighters in last 7 days
  int _calculateAllNighters(List<SleepEntry> sleepEntries) {
    return sleepEntries.where((s) => s.hoursSlept < 4).length;
  }

  /// Calculate average stress level
  double _calculateAverageStress(List<WellbeingCheckIn> checkIns) {
    if (checkIns.isEmpty) return 0.0;

    final totalStress = checkIns.fold<int>(
      0,
      (sum, c) => sum + c.stressLevel,
    );

    return totalStress / checkIns.length;
  }

  /// Calculate average sleep hours
  double _calculateAverageSleep(List<SleepEntry> sleepEntries) {
    if (sleepEntries.isEmpty) return 7.0;

    final totalHours = sleepEntries.fold<double>(
      0.0,
      (sum, s) => sum + s.hoursSlept,
    );

    return totalHours / sleepEntries.length;
  }

  /// Calculate overall risk score (0-100)
  double _calculateRiskScore({
    required int consecutiveLongDays,
    required int missedBreaks,
    required int allNighters,
    required double avgStressLevel,
    required double avgSleepHours,
    required int studyHoursThisWeek,
  }) {
    double score = 0.0;

    // Consecutive long days: 0-25 points
    score += (consecutiveLongDays * 5).clamp(0, 25).toDouble();

    // Missed breaks: 0-15 points
    score += (missedBreaks * 2).clamp(0, 15).toDouble();

    // All-nighters: 0-20 points
    score += (allNighters * 10).clamp(0, 20).toDouble();

    // Average stress level: 0-20 points
    score += ((avgStressLevel - 5) * 4).clamp(0, 20);

    // Sleep deprivation: 0-20 points
    if (avgSleepHours < 7) {
      score += ((7 - avgSleepHours) * 5).clamp(0, 20);
    }

    // Study overload: 0-10 points
    if (studyHoursThisWeek > 50) {
      score += ((studyHoursThisWeek - 50) / 5).clamp(0, 10);
    }

    return score.clamp(0, 100);
  }

  /// Determine risk level from score
  BurnoutRiskLevel _determineRiskLevel(double score) {
    if (score >= 81) return BurnoutRiskLevel.critical;
    if (score >= 61) return BurnoutRiskLevel.high;
    if (score >= 31) return BurnoutRiskLevel.moderate;
    return BurnoutRiskLevel.low;
  }

  /// Analyze weekly well-being trends
  WellbeingTrend analyzeWeeklyTrend(List<WellbeingCheckIn> checkIns) {
    if (checkIns.length < 2) {
      return WellbeingTrend(
        direction: TrendDirection.stable,
        change: 0.0,
        interpretation: 'Need more data to determine trend',
      );
    }

    // Sort by date
    checkIns.sort((a, b) => a.date.compareTo(b.date));

    final firstHalf = checkIns.take(checkIns.length ~/ 2).toList();
    final secondHalf = checkIns.skip(checkIns.length ~/ 2).toList();

    final firstAvg = firstHalf.fold<double>(
          0.0,
          (sum, c) => sum + c.overallWellbeingScore,
        ) /
        firstHalf.length;

    final secondAvg = secondHalf.fold<double>(
          0.0,
          (sum, c) => sum + c.overallWellbeingScore,
        ) /
        secondHalf.length;

    final change = secondAvg - firstAvg;

    TrendDirection direction;
    String interpretation;

    if (change > 5) {
      direction = TrendDirection.improving;
      interpretation = 'Your well-being is improving! Keep up the good work.';
    } else if (change < -5) {
      direction = TrendDirection.declining;
      interpretation = 'Your well-being is declining. Consider taking action.';
    } else {
      direction = TrendDirection.stable;
      interpretation = 'Your well-being is stable.';
    }

    return WellbeingTrend(
      direction: direction,
      change: change,
      interpretation: interpretation,
    );
  }

  /// Generate study load warning
  StudyLoadWarning? checkStudyLoad({
    required String userId,
    required int scheduledHoursToday,
    required int scheduledHoursThisWeek,
    required WellbeingCheckIn? todaysCheckIn,
  }) {
    WarningLevel? level;
    String? message;
    int? recommendedHours;

    // Check daily overload
    if (scheduledHoursToday > 14) {
      level = WarningLevel.critical;
      message = 'CRITICAL: 14+ hours of study is dangerous and ineffective';
      recommendedHours = 10;
    } else if (scheduledHoursToday > 12) {
      level = WarningLevel.warning;
      message = 'WARNING: 12+ hours of study increases burnout risk significantly';
      recommendedHours = 10;
    } else if (scheduledHoursToday > 10) {
      level = WarningLevel.caution;
      message = 'CAUTION: 10+ hours is a very long study day';
      recommendedHours = 8;
    }

    // Check weekly overload
    if (scheduledHoursThisWeek > 70) {
      level = WarningLevel.critical;
      message = 'CRITICAL: 70+ hours/week is unsustainable';
      recommendedHours = 50;
    } else if (scheduledHoursThisWeek > 60) {
      level = WarningLevel.warning;
      message = 'WARNING: 60+ hours/week greatly increases burnout risk';
      recommendedHours = 50;
    }

    // Check if user is already stressed
    if (todaysCheckIn != null && todaysCheckIn.stressLevel >= 8) {
      if (scheduledHoursToday > 8) {
        level = WarningLevel.warning;
        message = 'You\'re already stressed. Consider reducing today\'s study load.';
        recommendedHours = 6;
      }
    }

    if (level == null) return null;

    return StudyLoadWarning(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      date: DateTime.now(),
      level: level,
      message: message!,
      scheduledHours: scheduledHoursToday,
      recommendedHours: recommendedHours!,
    );
  }

  /// Calculate focus efficiency score
  double calculateFocusEfficiency({
    required int focusMinutes,
    required int distractionMinutes,
    required int distractionEvents,
  }) {
    final totalMinutes = focusMinutes + distractionMinutes;
    if (totalMinutes == 0) return 0.0;

    final focusRatio = focusMinutes / totalMinutes;

    // Penalty for frequent context switches
    final distractionPenalty = (distractionEvents * 0.05).clamp(0, 0.3);

    final efficiency = ((focusRatio - distractionPenalty) * 100).clamp(0, 100);

    return efficiency;
  }

  /// Recommend break schedule based on study load
  List<BreakReminder> recommendBreakSchedule({
    required String userId,
    required DateTime studyStartTime,
    required int plannedStudyMinutes,
  }) {
    final breaks = <BreakReminder>[];
    var currentTime = studyStartTime;

    // Pomodoro technique: 25 min work, 5 min break
    int pomodoroCount = 0;

    while (currentTime.difference(studyStartTime).inMinutes < plannedStudyMinutes) {
      pomodoroCount++;

      // Work for 25 minutes
      currentTime = currentTime.add(const Duration(minutes: 25));

      if (currentTime.difference(studyStartTime).inMinutes >= plannedStudyMinutes) {
        break;
      }

      // Add break
      if (pomodoroCount % 4 == 0) {
        // Long break every 4 pomodoros
        breaks.add(BreakReminder(
          id: DateTime.now().millisecondsSinceEpoch.toString() + pomodoroCount.toString(),
          userId: userId,
          scheduledTime: currentTime,
          type: BreakType.pomodoroLong,
          durationMinutes: 15,
        ));
        currentTime = currentTime.add(const Duration(minutes: 15));
      } else {
        // Short break
        breaks.add(BreakReminder(
          id: DateTime.now().millisecondsSinceEpoch.toString() + pomodoroCount.toString(),
          userId: userId,
          scheduledTime: currentTime,
          type: BreakType.pomodoro,
          durationMinutes: 5,
        ));
        currentTime = currentTime.add(const Duration(minutes: 5));
      }
    }

    return breaks;
  }
}

/// Well-being trend analysis
class WellbeingTrend {
  final TrendDirection direction;
  final double change;
  final String interpretation;

  const WellbeingTrend({
    required this.direction,
    required this.change,
    required this.interpretation,
  });
}

/// Trend direction
enum TrendDirection {
  improving,
  stable,
  declining,
}
