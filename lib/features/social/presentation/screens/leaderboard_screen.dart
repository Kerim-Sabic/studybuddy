import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Global and friend leaderboards with multiple categories
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardCategory _selectedCategory = LeaderboardCategory.xp;
  LeaderboardScope _scope = LeaderboardScope.global;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global', icon: Icon(Icons.public)),
            Tab(text: 'Friends', icon: Icon(Icons.people)),
          ],
          onTap: (index) {
            setState(() {
              _scope = index == 0
                  ? LeaderboardScope.global
                  : LeaderboardScope.friends;
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: LeaderboardCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(_getCategoryLabel(category)),
                      avatar: Icon(
                        _getCategoryIcon(category),
                        size: 18,
                        color: isSelected ? Colors.white : null,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Current user rank card
          _buildCurrentUserRank(),

          const SizedBox(height: 8),

          // Leaderboard list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(LeaderboardScope.global),
                _buildLeaderboardList(LeaderboardScope.friends),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserRank() {
    // Mock current user data
    final currentUser = LeaderboardEntry(
      userId: 'current-user',
      username: 'You',
      avatarUrl: null,
      rank: 42,
      value: 8450,
      change: 3, // Moved up 3 positions
      level: 12,
      badge: '🎯',
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    '#${currentUser.rank}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentUser.username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv ${currentUser.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatValue(currentUser.value)} ${_getUnitLabel(_selectedCategory)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Rank change
              if (currentUser.change != 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: currentUser.change > 0
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        currentUser.change > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: currentUser.change > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentUser.change.abs()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: currentUser.change > 0
                              ? Colors.green
                              : Colors.red,
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

  Widget _buildLeaderboardList(LeaderboardScope scope) {
    // Mock leaderboard data
    final entries = _getMockLeaderboardData(scope);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardEntry(entry);
      },
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry) {
    final isTopThree = entry.rank <= 3;
    final medalEmoji = entry.rank == 1
        ? '🥇'
        : entry.rank == 2
            ? '🥈'
            : entry.rank == 3
                ? '🥉'
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: isTopThree
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: entry.rank == 1
                        ? [Colors.amber.withOpacity(0.3), Colors.orange.withOpacity(0.1)]
                        : entry.rank == 2
                            ? [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)]
                            : [Colors.brown.withOpacity(0.3), Colors.brown.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 50,
                child: Center(
                  child: medalEmoji != null
                      ? Text(
                          medalEmoji,
                          style: const TextStyle(fontSize: 32),
                        )
                      : Text(
                          '#${entry.rank}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue,
                child: Text(
                  entry.username[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (entry.badge != null)
                          Text(
                            entry.badge!,
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${entry.level}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatValue(entry.value),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getUnitLabel(_selectedCategory),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Rank change indicator
              if (entry.change != 0)
                Icon(
                  entry.change > 0 ? Icons.trending_up : Icons.trending_down,
                  color: entry.change > 0 ? Colors.green : Colors.red,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.xp:
        return 'Total XP';
      case LeaderboardCategory.streak:
        return 'Streak';
      case LeaderboardCategory.studyTime:
        return 'Study Time';
      case LeaderboardCategory.flashcards:
        return 'Flashcards';
      case LeaderboardCategory.quizzes:
        return 'Quizzes';
    }
  }

  IconData _getCategoryIcon(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.xp:
        return Icons.stars;
      case LeaderboardCategory.streak:
        return Icons.local_fire_department;
      case LeaderboardCategory.studyTime:
        return Icons.access_time;
      case LeaderboardCategory.flashcards:
        return Icons.style;
      case LeaderboardCategory.quizzes:
        return Icons.quiz;
    }
  }

  String _getUnitLabel(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.xp:
        return 'XP';
      case LeaderboardCategory.streak:
        return 'days';
      case LeaderboardCategory.studyTime:
        return 'hours';
      case LeaderboardCategory.flashcards:
        return 'cards';
      case LeaderboardCategory.quizzes:
        return 'quizzes';
    }
  }

  String _formatValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  List<LeaderboardEntry> _getMockLeaderboardData(LeaderboardScope scope) {
    // Mock data - would come from database in real implementation
    final mockData = [
      LeaderboardEntry(
        userId: '1',
        username: 'StudyMaster3000',
        avatarUrl: null,
        rank: 1,
        value: 125000,
        change: 0,
        level: 24,
        badge: '👑',
      ),
      LeaderboardEntry(
        userId: '2',
        username: 'BrainiacAlex',
        avatarUrl: null,
        rank: 2,
        value: 98500,
        change: 1,
        level: 22,
        badge: '🧠',
      ),
      LeaderboardEntry(
        userId: '3',
        username: 'FlashcardQueen',
        avatarUrl: null,
        rank: 3,
        value: 87200,
        change: -1,
        level: 21,
        badge: '📚',
      ),
      LeaderboardEntry(
        userId: '4',
        username: 'QuantumLearner',
        avatarUrl: null,
        rank: 4,
        value: 76300,
        change: 2,
        level: 19,
        badge: '⚡',
      ),
      LeaderboardEntry(
        userId: '5',
        username: 'MindMapMike',
        avatarUrl: null,
        rank: 5,
        value: 68900,
        change: 0,
        level: 18,
        badge: '🗺️',
      ),
    ];

    return mockData;
  }
}

enum LeaderboardCategory {
  xp,
  streak,
  studyTime,
  flashcards,
  quizzes,
}

enum LeaderboardScope {
  global,
  friends,
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int rank;
  final int value;
  final int change; // Position change from last period
  final int level;
  final String? badge;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.rank,
    required this.value,
    required this.change,
    required this.level,
    this.badge,
  });
}
