import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Fun, engaging onboarding experience for students
class FunOnboardingScreen extends StatefulWidget {
  const FunOnboardingScreen({super.key});

  @override
  State<FunOnboardingScreen> createState() => _FunOnboardingScreenState();
}

class _FunOnboardingScreenState extends State<FunOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '👋',
      title: 'Welcome to StudyBuddy!',
      description: 'Your AI-powered study companion is here to make learning fun, effective, and stress-free!',
      color: Colors.blue,
    ),
    OnboardingPage(
      emoji: '🧠',
      title: 'Science-Backed Learning',
      description: 'Master concepts 3x faster with proven techniques like spaced repetition, Feynman technique, and mind mapping!',
      color: Colors.purple,
    ),
    OnboardingPage(
      emoji: '🎮',
      title: 'Level Up Your Brain',
      description: 'Earn XP, unlock badges, climb leaderboards, and compete with friends while you study!',
      color: Colors.amber,
    ),
    OnboardingPage(
      emoji: '🤖',
      title: 'Your AI Study Coach',
      description: 'Get instant help, personalized study plans, and smart recommendations powered by DeepSeek AI!',
      color: Colors.green,
    ),
    OnboardingPage(
      emoji: '🌳',
      title: 'Plant Trees While You Focus',
      description: 'Stay focused and watch your virtual forest grow! Every study session helps save the planet 🌍',
      color: Colors.teal,
    ),
    OnboardingPage(
      emoji: '👥',
      title: 'Study Together, Succeed Together',
      description: 'Join study groups, challenge friends, and share resources with your study squad!',
      color: Colors.pink,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Mark onboarding as complete and navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pages[_currentPage].color.withOpacity(0.3),
                  _pages[_currentPage].color.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? '🎉 Get Started!'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Text(
                  page.emoji,
                  style: const TextStyle(fontSize: 120),
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Fun fact or tip
          GlassCard(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: page.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getFunFact(_currentPage),
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFunFact(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return '90% of students say StudyBuddy improved their grades!';
      case 1:
        return 'Fun fact: Spaced repetition can boost retention by 200%!';
      case 2:
        return 'Gamification makes studying 5x more engaging!';
      case 3:
        return 'DeepSeek AI is 10x faster and more affordable than alternatives!';
      case 4:
        return 'Our community has planted over 10,000 real trees!';
      case 5:
        return 'Students in study groups score 15% higher on exams!';
      default:
        return 'You\'ve got this! 💪';
    }
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
