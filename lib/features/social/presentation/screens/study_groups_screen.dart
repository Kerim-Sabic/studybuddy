import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Study groups - create, join, collaborate with peers
class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Study Groups'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Groups', icon: Icon(Icons.groups)),
            Tab(text: 'Discover', icon: Icon(Icons.explore)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGroupDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroupsList(),
          _buildDiscoverList(),
        ],
      ),
    );
  }

  Widget _buildMyGroupsList() {
    final myGroups = _getMockMyGroups();

    if (myGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No study groups yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Join or create a group to get started!'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Group'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myGroups.length,
      itemBuilder: (context, index) {
        final group = myGroups[index];
        return _buildGroupCard(group, isMember: true);
      },
    );
  }

  Widget _buildDiscoverList() {
    final discoverGroups = _getMockDiscoverGroups();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: discoverGroups.length,
      itemBuilder: (context, index) {
        final group = discoverGroups[index];
        return _buildGroupCard(group, isMember: false);
      },
    );
  }

  Widget _buildGroupCard(StudyGroup group, {required bool isMember}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: InkWell(
          onTap: () => _openGroupDetails(group),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Group icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _getGroupColor(group.category),
                            _getGroupColor(group.category).withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          group.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Group info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${group.memberCount} members',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: group.isPrivate
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      group.isPrivate ? Icons.lock : Icons.public,
                                      size: 12,
                                      color: group.isPrivate
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      group.isPrivate ? 'Private' : 'Public',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: group.isPrivate
                                            ? Colors.orange
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Activity indicator
                    if (group.hasNewActivity)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  group.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => isMember
                        ? _openGroupDetails(group)
                        : _joinGroup(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isMember ? Colors.blue : Colors.green,
                    ),
                    child: Text(
                      isMember ? 'Open Group' : 'Join Group',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Computer Science';
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Study Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'e.g., CS 101 Study Group',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this group about?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Computer Science',
                    'Mathematics',
                    'Physics',
                    'Chemistry',
                    'Biology',
                    'Engineering',
                    'Languages',
                    'Business',
                    'Other',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Private Group'),
                  subtitle: const Text('Require approval to join'),
                  value: isPrivate,
                  onChanged: (value) {
                    setDialogState(() {
                      isPrivate = value;
                    });
                  },
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
                if (nameController.text.isNotEmpty) {
                  // Create group
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Study group created!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _openGroupDetails(StudyGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(group: group),
      ),
    );
  }

  void _joinGroup(StudyGroup group) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          group.isPrivate
              ? '📧 Join request sent!'
              : '✅ Joined ${group.name}!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getGroupColor(String category) {
    switch (category) {
      case 'Computer Science':
        return Colors.blue;
      case 'Mathematics':
        return Colors.purple;
      case 'Physics':
        return Colors.orange;
      case 'Chemistry':
        return Colors.green;
      case 'Biology':
        return Colors.teal;
      case 'Engineering':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<StudyGroup> _getMockMyGroups() {
    return [
      StudyGroup(
        id: '1',
        name: 'CS 101 Finals Prep',
        description: 'Preparing for the final exam together. Daily study sessions!',
        category: 'Computer Science',
        emoji: '💻',
        memberCount: 24,
        isPrivate: false,
        tags: ['Finals', 'Algorithms', 'Data Structures'],
        hasNewActivity: true,
      ),
      StudyGroup(
        id: '2',
        name: 'Calculus Warriors',
        description: 'Conquering calculus one derivative at a time',
        category: 'Mathematics',
        emoji: '📐',
        memberCount: 18,
        isPrivate: false,
        tags: ['Calculus', 'Midterm', 'Problem Sets'],
        hasNewActivity: false,
      ),
    ];
  }

  List<StudyGroup> _getMockDiscoverGroups() {
    return [
      StudyGroup(
        id: '3',
        name: 'Quantum Physics Study Circle',
        description: 'Exploring quantum mechanics and modern physics together',
        category: 'Physics',
        emoji: '⚛️',
        memberCount: 32,
        isPrivate: false,
        tags: ['Quantum Mechanics', 'Graduate Level'],
        hasNewActivity: false,
      ),
      StudyGroup(
        id: '4',
        name: 'Organic Chemistry Masters',
        description: 'Master organic chemistry reactions and mechanisms',
        category: 'Chemistry',
        emoji: '🧪',
        memberCount: 45,
        isPrivate: true,
        tags: ['Organic Chemistry', 'MCAT Prep'],
        hasNewActivity: false,
      ),
    ];
  }
}

class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String category;
  final String emoji;
  final int memberCount;
  final bool isPrivate;
  final List<String> tags;
  final bool hasNewActivity;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.emoji,
    required this.memberCount,
    required this.isPrivate,
    required this.tags,
    required this.hasNewActivity,
  });
}

/// Group details screen with chat and members
class GroupDetailsScreen extends StatefulWidget {
  final StudyGroup group;

  const GroupDetailsScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chat', icon: Icon(Icons.chat)),
            Tab(text: 'Members', icon: Icon(Icons.people)),
            Tab(text: 'Resources', icon: Icon(Icons.folder)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildMembersTab(),
          _buildResourcesTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    final messages = _getMockMessages();

    return Column(
      children: [
        // Messages list
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[messages.length - 1 - index];
              final isMe = message.isMe;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: GlassCard(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              message.username,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          if (!isMe) const SizedBox(height: 4),
                          Text(message.text),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                color: Colors.blue,
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    // Send message
                    _messageController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    final members = _getMockMembers();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return GlassCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                member.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Row(
              children: [
                Text(member.username),
                const SizedBox(width: 8),
                if (member.isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text('Level ${member.level} • ${member.xp} XP'),
            trailing: member.isOnline
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildResourcesTab() {
    final resources = _getMockResources();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return GlassCard(
          child: ListTile(
            leading: Icon(
              _getResourceIcon(resource.type),
              color: Colors.blue,
            ),
            title: Text(resource.title),
            subtitle: Text('Shared by ${resource.sharedBy}'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading...')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'link':
        return Icons.link;
      case 'notes':
        return Icons.note;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  List<ChatMessage> _getMockMessages() {
    return [
      ChatMessage(
        username: 'You',
        text: 'Hey everyone! Ready for tomorrow\'s study session?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: true,
      ),
      ChatMessage(
        username: 'Alice',
        text: 'Absolutely! I\'ll bring my notes on dynamic programming.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isMe: false,
      ),
      ChatMessage(
        username: 'Bob',
        text: 'Can someone explain binary search trees again?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isMe: false,
      ),
    ];
  }

  List<GroupMember> _getMockMembers() {
    return [
      GroupMember(
        username: 'You',
        level: 12,
        xp: 8450,
        isAdmin: true,
        isOnline: true,
      ),
      GroupMember(
        username: 'Alice',
        level: 15,
        xp: 12300,
        isAdmin: false,
        isOnline: true,
      ),
      GroupMember(
        username: 'Bob',
        level: 10,
        xp: 6800,
        isAdmin: false,
        isOnline: false,
      ),
    ];
  }

  List<GroupResource> _getMockResources() {
    return [
      GroupResource(
        title: 'Algorithms Cheat Sheet.pdf',
        type: 'pdf',
        sharedBy: 'Alice',
      ),
      GroupResource(
        title: 'Helpful YouTube Tutorial',
        type: 'link',
        sharedBy: 'Bob',
      ),
    ];
  }
}

class ChatMessage {
  final String username;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.username,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class GroupMember {
  final String username;
  final int level;
  final int xp;
  final bool isAdmin;
  final bool isOnline;

  GroupMember({
    required this.username,
    required this.level,
    required this.xp,
    required this.isAdmin,
    required this.isOnline,
  });
}

class GroupResource {
  final String title;
  final String type;
  final String sharedBy;

  GroupResource({
    required this.title,
    required this.type,
    required this.sharedBy,
  });
}
