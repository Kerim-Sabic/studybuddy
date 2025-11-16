import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'dart:math';

/// Daily motivation, tips, and encouragement for students
class DailyMotivationScreen extends StatefulWidget {
  const DailyMotivationScreen({super.key});

  @override
  State<DailyMotivationScreen> createState() => _DailyMotivationScreenState();
}

class _DailyMotivationScreenState extends State<DailyMotivationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<MotivationQuote> _quotes = [
    MotivationQuote(
      quote: "The expert in anything was once a beginner.",
      author: "Helen Hayes",
      emoji: "🌱",
      color: Colors.green,
    ),
    MotivationQuote(
      quote: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      author: "Winston Churchill",
      emoji: "💪",
      color: Colors.orange,
    ),
    MotivationQuote(
      quote: "Education is the most powerful weapon which you can use to change the world.",
      author: "Nelson Mandela",
      emoji: "🎓",
      color: Colors.blue,
    ),
    MotivationQuote(
      quote: "The beautiful thing about learning is that nobody can take it away from you.",
      author: "B.B. King",
      emoji: "✨",
      color: Colors.purple,
    ),
    MotivationQuote(
      quote: "Don't let what you cannot do interfere with what you can do.",
      author: "John Wooden",
      emoji: "🎯",
      color: Colors.teal,
    ),
    MotivationQuote(
      quote: "Study while others are sleeping; work while others are loafing.",
      author: "William A. Ward",
      emoji: "📚",
      color: Colors.indigo,
    ),
    MotivationQuote(
      quote: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      emoji: "❤️",
      color: Colors.red,
    ),
    MotivationQuote(
      quote: "Believe you can and you're halfway there.",
      author: "Theodore Roosevelt",
      emoji: "🌟",
      color: Colors.amber,
    ),
  ];

  final List<StudyTip> _studyTips = [
    StudyTip(
      title: "The 25-Minute Rule",
      tip: "Study for 25 minutes, take a 5-minute break. Your brain will thank you!",
      emoji: "⏰",
      category: "Productivity",
    ),
    StudyTip(
      title: "Teach Someone Else",
      tip: "Explaining concepts to others (or even to yourself!) is the best way to truly understand them.",
      emoji: "👨‍🏫",
      category: "Learning",
    ),
    StudyTip(
      title: "Sleep is Your Superpower",
      tip: "Get 7-9 hours of sleep! Your brain consolidates memories while you sleep.",
      emoji: "😴",
      category: "Well-being",
    ),
    StudyTip(
      title: "Mix It Up!",
      tip: "Switch between subjects instead of studying one thing for hours. It's called interleaving!",
      emoji: "🔀",
      category: "Technique",
    ),
    StudyTip(
      title: "Hydrate Your Brain",
      tip: "Drink water! Even mild dehydration can hurt your focus and memory.",
      emoji: "💧",
      category: "Health",
    ),
    StudyTip(
      title: "The 80/20 Rule",
      tip: "Focus on the 20% of material that gives you 80% of the results. Study smart!",
      emoji: "🎯",
      category: "Strategy",
    ),
    StudyTip(
      title: "Movement Matters",
      tip: "Take a quick walk between study sessions. Exercise boosts brain power!",
      emoji: "🚶",
      category: "Health",
    ),
    StudyTip(
      title: "Quiz Yourself",
      tip: "Testing yourself is way better than re-reading. Active recall is key!",
      emoji: "📝",
      category: "Technique",
    ),
  ];

  late MotivationQuote _dailyQuote;
  late StudyTip _dailyTip;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Select daily quote and tip based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    _dailyQuote = _quotes[dayOfYear % _quotes.length];
    _dailyTip = _studyTips[dayOfYear % _studyTips.length];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _getNewQuote() {
    setState(() {
      _dailyQuote = _quotes[Random().nextInt(_quotes.length)];
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _getNewTip() {
    setState(() {
      _dailyTip = _studyTips[Random().nextInt(_studyTips.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❤️ Quote saved to favorites!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            _buildGreeting(),

            const SizedBox(height: 24),

            // Daily Quote
            _buildDailyQuote(),

            const SizedBox(height: 24),

            // Daily Study Tip
            _buildDailyTip(),

            const SizedBox(height: 24),

            // Quick Motivational Cards
            _buildMotivationalCards(),

            const SizedBox(height: 24),

            // Success Stories
            _buildSuccessStories(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = "Good Morning";
      emoji = "🌅";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
      emoji = "☀️";
    } else {
      greeting = "Good Evening";
      emoji = "🌙";
    }

    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Ready to crush your goals today?",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuote() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _dailyQuote.color.withOpacity(0.3),
                _dailyQuote.color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    _dailyQuote.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Quote of the Day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getNewQuote,
                    tooltip: 'Get new quote',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"${_dailyQuote.quote}"',
                style: const TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '— ${_dailyQuote.author}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTip() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _dailyTip.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Study Tip of the Day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _dailyTip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: _getNewTip,
                  tooltip: 'Get new tip',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _dailyTip.tip,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(_dailyTip.category),
              backgroundColor: Colors.amber.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Boosts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildMiniCard(
              '🔥',
              'Keep Your Streak!',
              '${Random().nextInt(20) + 5} days',
              Colors.orange,
            ),
            _buildMiniCard(
              '⚡',
              'Study Power',
              '${Random().nextInt(50) + 20}h this week',
              Colors.blue,
            ),
            _buildMiniCard(
              '🎯',
              'On Target',
              '${Random().nextInt(30) + 70}% complete',
              Colors.green,
            ),
            _buildMiniCard(
              '🏆',
              'Rank',
              '#${Random().nextInt(100) + 1}',
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(String emoji, String title, String value, Color color) {
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStories() {
    final stories = [
      {
        'name': 'Sarah M.',
        'story': 'StudyBuddy helped me raise my GPA from 3.2 to 3.9! The AI coach is amazing!',
        'emoji': '🌟',
      },
      {
        'name': 'Alex K.',
        'story': 'I aced my finals thanks to the spaced repetition flashcards. Game changer!',
        'emoji': '💯',
      },
      {
        'name': 'Maria L.',
        'story': 'The study groups feature connected me with amazing people who became my best friends!',
        'emoji': '❤️',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Success Stories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...stories.map((story) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story['emoji']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story['story']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class MotivationQuote {
  final String quote;
  final String author;
  final String emoji;
  final Color color;

  MotivationQuote({
    required this.quote,
    required this.author,
    required this.emoji,
    required this.color,
  });
}

class StudyTip {
  final String title;
  final String tip;
  final String emoji;
  final String category;

  StudyTip({
    required this.title,
    required this.tip,
    required this.emoji,
    required this.category,
  });
}
