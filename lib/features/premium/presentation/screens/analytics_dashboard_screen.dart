import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'dart:math' as math;

/// Premium Analytics Dashboard - Advanced insights and visualizations
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  TimeRange _selectedTimeRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          PopupMenuButton<TimeRange>(
            icon: const Icon(Icons.date_range),
            onSelected: (range) {
              setState(() {
                _selectedTimeRange = range;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TimeRange.week,
                child: Text('This Week'),
              ),
              const PopupMenuItem(
                value: TimeRange.month,
                child: Text('This Month'),
              ),
              const PopupMenuItem(
                value: TimeRange.quarter,
                child: Text('This Quarter'),
              ),
              const PopupMenuItem(
                value: TimeRange.year,
                child: Text('This Year'),
              ),
              const PopupMenuItem(
                value: TimeRange.allTime,
                child: Text('All Time'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key metrics overview
            _buildKeyMetricsSection(),

            const SizedBox(height: 24),

            // Study time chart
            _buildStudyTimeChart(),

            const SizedBox(height: 24),

            // Performance by subject
            _buildSubjectPerformanceSection(),

            const SizedBox(height: 24),

            // Retention & Memory analysis
            _buildRetentionAnalysisSection(),

            const SizedBox(height: 24),

            // Productivity heatmap
            _buildProductivityHeatmap(),

            const SizedBox(height: 24),

            // Learning velocity
            _buildLearningVelocitySection(),

            const SizedBox(height: 24),

            // Goal progress
            _buildGoalProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              title: 'Study Time',
              value: '42.5',
              unit: 'hours',
              change: '+12%',
              isPositive: true,
              icon: Icons.access_time,
              color: Colors.blue,
            ),
            _buildMetricCard(
              title: 'Retention Rate',
              value: '87',
              unit: '%',
              change: '+5%',
              isPositive: true,
              icon: Icons.psychology,
              color: Colors.purple,
            ),
            _buildMetricCard(
              title: 'Cards Reviewed',
              value: '1,247',
              unit: 'cards',
              change: '+23%',
              isPositive: true,
              icon: Icons.style,
              color: Colors.green,
            ),
            _buildMetricCard(
              title: 'Focus Sessions',
              value: '18',
              unit: 'sessions',
              change: '-2',
              isPositive: false,
              icon: Icons.eco,
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        change.replaceAll('+', '').replaceAll('-', ''),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeChart() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Time Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _SimpleBarChart(
                data: _getStudyTimeData(),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceSection() {
    final subjects = [
      SubjectPerformance('Computer Science', 92, Colors.blue),
      SubjectPerformance('Mathematics', 87, Colors.purple),
      SubjectPerformance('Physics', 78, Colors.orange),
      SubjectPerformance('Chemistry', 85, Colors.green),
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance by Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...subjects.map((subject) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${subject.score}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: subject.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: subject.score / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(subject.color),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionAnalysisSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Retention Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRetentionMetric(
                    'Immediate',
                    '95%',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    '1 Day',
                    '87%',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    '1 Week',
                    '72%',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    '1 Month',
                    '58%',
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '💡 Tip: Your retention drops significantly after 1 week. Try reviewing cards more frequently!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductivityHeatmap() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productivity Heatmap',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Study activity by day and hour',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hours = ['6AM', '12PM', '6PM'];

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 40),
            ...hours.map((hour) {
              return Expanded(
                child: Center(
                  child: Text(
                    hour,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(7, (dayIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    days[dayIndex],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                ...List.generate(3, (hourIndex) {
                  final intensity = (math.Random().nextDouble() * 5).toInt();
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(intensity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeatmapLegend(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      children: [
        const Text('Less', style: TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        ...List.generate(5, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getHeatmapColor(i),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }).toList(),
        const SizedBox(width: 4),
        const Text('More', style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Color _getHeatmapColor(int intensity) {
    switch (intensity) {
      case 0:
        return Colors.grey[200]!;
      case 1:
        return Colors.green[100]!;
      case 2:
        return Colors.green[300]!;
      case 3:
        return Colors.green[500]!;
      case 4:
        return Colors.green[700]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Widget _buildLearningVelocitySection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Velocity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New concepts mastered per week',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVelocityIndicator('This Week', 12, Colors.blue),
                _buildVelocityIndicator('Last Week', 8, Colors.grey),
                _buildVelocityIndicator('Average', 10, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            const Text(
              '📈 You\'re learning 20% faster than last month!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVelocityIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgressSection() {
    final goals = [
      Goal('Complete CS 101', 0.85, Colors.blue),
      Goal('Master Calculus', 0.60, Colors.purple),
      Goal('1000 Flashcards', 0.45, Colors.green),
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...goals.map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(goal.name),
                        Text(
                          '${(goal.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: goal.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(goal.color),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<ChartData> _getStudyTimeData() {
    return [
      ChartData('Mon', 5.5),
      ChartData('Tue', 6.2),
      ChartData('Wed', 4.8),
      ChartData('Thu', 7.1),
      ChartData('Fri', 5.9),
      ChartData('Sat', 8.3),
      ChartData('Sun', 4.7),
    ];
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<ChartData> data;
  final Color color;

  const _SimpleBarChart({
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((d) => d.value).reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((item) {
        final heightRatio = item.value / maxValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  item.value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 150 * heightRatio,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

enum TimeRange {
  week,
  month,
  quarter,
  year,
  allTime,
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}

class SubjectPerformance {
  final String name;
  final int score;
  final Color color;

  SubjectPerformance(this.name, this.score, this.color);
}

class Goal {
  final String name;
  final double progress;
  final Color color;

  Goal(this.name, this.progress, this.color);
}
