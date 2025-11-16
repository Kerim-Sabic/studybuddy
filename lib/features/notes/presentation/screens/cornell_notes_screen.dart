import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'package:studybuddy/features/notes/domain/entities/note.dart';

/// Cornell Notes Template Screen
/// Uses the Cornell Note-Taking System: Cues | Notes | Summary
class CornellNotesScreen extends StatefulWidget {
  final String? courseId;
  final String? courseName;
  final Note? existingNote;

  const CornellNotesScreen({
    super.key,
    this.courseId,
    this.courseName,
    this.existingNote,
  });

  @override
  State<CornellNotesScreen> createState() => _CornellNotesScreenState();
}

class _CornellNotesScreenState extends State<CornellNotesScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _summaryController;
  final List<CornellCue> _cues = [];
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );
    _summaryController = TextEditingController(
      text: widget.existingNote?.cornellSummary ?? '',
    );

    // Load existing cues if editing
    if (widget.existingNote?.cornellCues != null &&
        widget.existingNote!.cornellCues!.isNotEmpty) {
      // Parse cues from JSON (simplified for now)
      _cues.addAll([
        CornellCue(question: 'Sample Cue', time: DateTime.now()),
      ]);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _addCue() {
    showDialog(
      context: context,
      builder: (context) {
        final cueController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Cue/Question'),
          content: TextField(
            controller: cueController,
            decoration: const InputDecoration(
              labelText: 'Key Question or Cue',
              hintText: 'What is the main idea?',
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cueController.text.isNotEmpty) {
                  setState(() {
                    _cues.add(CornellCue(
                      question: cueController.text,
                      time: DateTime.now(),
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveNote() {
    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Cornell notes saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cornell Notes'),
        actions: [
          if (_showInstructions)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('📝 Cornell Note-Taking System'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'How to use Cornell Notes:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          Text('1. CUES (Left): Key questions and keywords'),
                          Text('2. NOTES (Right): Detailed notes during lecture'),
                          Text('3. SUMMARY (Bottom): Summary after review'),
                          SizedBox(height: 16),
                          Text(
                            'Benefits:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('• Improves retention by 34%'),
                          Text('• Forces active review'),
                          Text('• Creates study questions automatically'),
                          Text('• Organizes information systematically'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it!'),
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                hintText: 'e.g., Chapter 5: Photosynthesis',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Cornell Layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: CUES (30%)
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'CUES & QUESTIONS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add_circle, size: 20),
                                onPressed: _addCue,
                                tooltip: 'Add Cue',
                              ),
                            ],
                          ),
                        ),

                        // Cues List
                        Expanded(
                          child: _cues.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline,
                                          size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap + to add\nkey questions',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _cues.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final cue = _cues[index];
                                    return Dismissible(
                                      key: Key('cue-$index'),
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 16),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (_) {
                                        setState(() {
                                          _cues.removeAt(index);
                                        });
                                      },
                                      child: GlassCard(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            cue.question,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Column: NOTES (70%)
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_note, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'NOTES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notes Text Area
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _notesController,
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText:
                                  'Take detailed notes here...\n\n• Use bullet points\n• Include examples\n• Draw diagrams if needed',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom: SUMMARY (20%)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 2),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.summarize, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'SUMMARY (Write after reviewing)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Summary Text Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _summaryController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText:
                            'Summarize the main ideas in 2-3 sentences...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        icon: const Icon(Icons.save),
        label: const Text('Save Cornell Notes'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Cornell Cue/Question model
class CornellCue {
  final String question;
  final DateTime time;

  CornellCue({
    required this.question,
    required this.time,
  });
}
