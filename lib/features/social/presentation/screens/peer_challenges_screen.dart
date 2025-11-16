import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Peer challenges - compete with friends on study metrics
class PeerChallengesScreen extends StatefulWidget {
  const PeerChallengesScreen({super.key});

  @override
  State<PeerChallengesScreen> createState() => _PeerChallengesScreenState();
}

class _PeerChallengesScreenState extends State<PeerChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.sports_esports)),
            Tab(text: 'Completed', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Create', icon: Icon(Icons.add_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveChallengesList(),
          _buildCompletedChallengesList(),
          _buildCreateChallengeTab(),
        ],
      ),
    );
  }

  Widget _buildActiveChallengesList() {
    final activeChallenges = _getMockActiveChallenges();

    if (activeChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No active challenges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Challenge a friend to get started!'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(2),
              icon: const Icon(Icons.add),
              label: const Text('Create Challenge'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeChallenges.length,
      itemBuilder: (context, index) {
        final challenge = activeChallenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildCompletedChallengesList() {
    final completedChallenges = _getMockCompletedChallenges();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedChallenges.length,
      itemBuilder: (context, index) {
        final challenge = completedChallenges[index];
        return _buildCompletedChallengeCard(challenge);
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final daysRemaining = challenge.endDate.difference(DateTime.now()).inDays;
    final progress = challenge.myProgress / challenge.goal;
    final opponentProgress = challenge.opponentProgress / challenge.goal;
    final isWinning = challenge.myProgress > challenge.opponentProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getChallengeColor(challenge.type).withOpacity(0.2),
                    ),
                    child: Icon(
                      _getChallengeIcon(challenge.type),
                      color: _getChallengeColor(challenge.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: daysRemaining <= 1
                          ? Colors.red.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$daysRemaining days left',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: daysRemaining <= 1 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // VS section
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerProgress(
                      name: 'You',
                      progress: challenge.myProgress,
                      goal: challenge.goal,
                      isWinning: isWinning,
                      isMe: true,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildPlayerProgress(
                      name: challenge.opponentName,
                      progress: challenge.opponentProgress,
                      goal: challenge.goal,
                      isWinning: !isWinning,
                      isMe: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bars comparison
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            isWinning ? Colors.green : Colors.blue,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LinearProgressIndicator(
                          value: opponentProgress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            !isWinning ? Colors.green : Colors.blue,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(opponentProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Prize/Reward
              if (challenge.reward != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prize: ${challenge.reward}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerProgress({
    required String name,
    required int progress,
    required int goal,
    required bool isWinning,
    required bool isMe,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: isWinning ? Colors.green : Colors.blue,
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$progress / $goal',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isWinning)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '🏆 Leading',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletedChallengeCard(Challenge challenge) {
    final won = challenge.myProgress >= challenge.opponentProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Result icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: won
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
                child: Text(
                  won ? '🏆' : '😔',
                  style: const TextStyle(fontSize: 32),
                ),
              ),

              const SizedBox(width: 16),

              // Challenge info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vs ${challenge.opponentName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      won
                          ? 'You won! ${challenge.myProgress} - ${challenge.opponentProgress}'
                          : 'You lost. ${challenge.myProgress} - ${challenge.opponentProgress}',
                      style: TextStyle(
                        fontSize: 14,
                        color: won ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // XP gained
              if (won && challenge.reward != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    challenge.reward!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateChallengeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Challenges',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Challenge a friend with pre-made templates',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Challenge templates
          _buildChallengeTemplate(
            title: 'Flashcard Sprint',
            description: 'Review 100 flashcards in 1 week',
            icon: Icons.style,
            color: Colors.blue,
            type: ChallengeType.flashcards,
            goal: 100,
            durationDays: 7,
          ),
          _buildChallengeTemplate(
            title: 'Study Marathon',
            description: 'Study for 20 hours this week',
            icon: Icons.access_time,
            color: Colors.purple,
            type: ChallengeType.studyTime,
            goal: 1200, // 20 hours in minutes
            durationDays: 7,
          ),
          _buildChallengeTemplate(
            title: 'XP Race',
            description: 'Earn 5,000 XP in 3 days',
            icon: Icons.stars,
            color: Colors.amber,
            type: ChallengeType.xp,
            goal: 5000,
            durationDays: 3,
          ),
          _buildChallengeTemplate(
            title: 'Quiz Master',
            description: 'Complete 10 quizzes this week',
            icon: Icons.quiz,
            color: Colors.green,
            type: ChallengeType.quizzes,
            goal: 10,
            durationDays: 7,
          ),
          _buildChallengeTemplate(
            title: 'Focus Champion',
            description: 'Complete 5 focus sessions',
            icon: Icons.eco,
            color: Colors.teal,
            type: ChallengeType.focusSessions,
            goal: 5,
            durationDays: 7,
          ),

          const SizedBox(height: 24),

          // Custom challenge button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateCustomChallengeDialog,
              icon: const Icon(Icons.add_circle),
              label: const Text('Create Custom Challenge'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTemplate({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ChallengeType type,
    required int goal,
    required int durationDays,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: () => _showSelectOpponentDialog(
            title: title,
            description: description,
            type: type,
            goal: goal,
            durationDays: durationDays,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectOpponentDialog({
    required String title,
    required String description,
    required ChallengeType type,
    required int goal,
    required int durationDays,
  }) {
    final friends = _getMockFriends();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Challenge: $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            const Text(
              'Select opponent:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...friends.map((friend) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(friend.username[0].toUpperCase()),
                ),
                title: Text(friend.username),
                subtitle: Text('Level ${friend.level}'),
                onTap: () {
                  Navigator.pop(context);
                  _sendChallenge(friend.username, title);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Challenge'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Challenge Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Goal (number)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Duration (days)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Would show opponent selection
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _sendChallenge(String opponentName, String challengeTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚔️ Challenge sent to $opponentName!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getChallengeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.flashcards:
        return Colors.blue;
      case ChallengeType.studyTime:
        return Colors.purple;
      case ChallengeType.xp:
        return Colors.amber;
      case ChallengeType.quizzes:
        return Colors.green;
      case ChallengeType.focusSessions:
        return Colors.teal;
    }
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.flashcards:
        return Icons.style;
      case ChallengeType.studyTime:
        return Icons.access_time;
      case ChallengeType.xp:
        return Icons.stars;
      case ChallengeType.quizzes:
        return Icons.quiz;
      case ChallengeType.focusSessions:
        return Icons.eco;
    }
  }

  List<Challenge> _getMockActiveChallenges() {
    return [
      Challenge(
        id: '1',
        title: 'Flashcard Sprint',
        description: 'Review 100 flashcards',
        type: ChallengeType.flashcards,
        goal: 100,
        myProgress: 67,
        opponentName: 'Alice',
        opponentProgress: 52,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        reward: '+500 XP',
      ),
      Challenge(
        id: '2',
        title: 'XP Race',
        description: 'Earn 5,000 XP',
        type: ChallengeType.xp,
        goal: 5000,
        myProgress: 3200,
        opponentName: 'Bob',
        opponentProgress: 3800,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        reward: '+1000 XP',
      ),
    ];
  }

  List<Challenge> _getMockCompletedChallenges() {
    return [
      Challenge(
        id: '3',
        title: 'Study Marathon',
        description: 'Study for 20 hours',
        type: ChallengeType.studyTime,
        goal: 1200,
        myProgress: 1250,
        opponentName: 'Charlie',
        opponentProgress: 1100,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        endDate: DateTime.now().subtract(const Duration(days: 7)),
        reward: '+750 XP',
      ),
      Challenge(
        id: '4',
        title: 'Quiz Master',
        description: 'Complete 10 quizzes',
        type: ChallengeType.quizzes,
        goal: 10,
        myProgress: 8,
        opponentName: 'Diana',
        opponentProgress: 10,
        startDate: DateTime.now().subtract(const Duration(days: 21)),
        endDate: DateTime.now().subtract(const Duration(days: 14)),
        reward: null,
      ),
    ];
  }

  List<Friend> _getMockFriends() {
    return [
      Friend(username: 'Alice', level: 15),
      Friend(username: 'Bob', level: 12),
      Friend(username: 'Charlie', level: 18),
      Friend(username: 'Diana', level: 10),
    ];
  }
}

enum ChallengeType {
  flashcards,
  studyTime,
  xp,
  quizzes,
  focusSessions,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int goal;
  final int myProgress;
  final String opponentName;
  final int opponentProgress;
  final DateTime startDate;
  final DateTime endDate;
  final String? reward;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.goal,
    required this.myProgress,
    required this.opponentName,
    required this.opponentProgress,
    required this.startDate,
    required this.endDate,
    this.reward,
  });
}

class Friend {
  final String username;
  final int level;

  const Friend({
    required this.username,
    required this.level,
  });
}
