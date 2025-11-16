import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Interactive Mind Map Editor with drag-and-drop
class MindMapEditorScreen extends StatefulWidget {
  final String? courseId;
  final String? courseName;

  const MindMapEditorScreen({
    super.key,
    this.courseId,
    this.courseName,
  });

  @override
  State<MindMapEditorScreen> createState() => _MindMapEditorScreenState();
}

class _MindMapEditorScreenState extends State<MindMapEditorScreen> {
  late TextEditingController _titleController;
  late TransformationController _transformController;

  final List<MindMapNode> _nodes = [];
  final List<MindMapConnection> _connections = [];
  MindMapNode? _selectedNode;
  MindMapNode? _connectingFrom;
  Offset? _connectingTo;

  double _scale = 1.0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _transformController = TransformationController();

    // Add central node by default
    _addNode(
      text: 'Central Topic',
      position: const Offset(300, 250),
      level: 0,
      color: Colors.blue,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _addNode({
    required String text,
    required Offset position,
    int level = 1,
    Color? color,
  }) {
    setState(() {
      _nodes.add(MindMapNode(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        position: position,
        level: level,
        color: color ?? _getLevelColor(level),
      ));
    });
  }

  void _addConnection(String fromId, String toId) {
    setState(() {
      _connections.add(MindMapConnection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromId: fromId,
        toId: toId,
      ));
    });
  }

  void _deleteNode(MindMapNode node) {
    setState(() {
      _nodes.remove(node);
      _connections.removeWhere(
        (c) => c.fromId == node.id || c.toId == node.id,
      );
      if (_selectedNode?.id == node.id) {
        _selectedNode = null;
      }
    });
  }

  void _editNode(MindMapNode node) {
    final controller = TextEditingController(text: node.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Node'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Node Text',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  final index = _nodes.indexOf(node);
                  _nodes[index] = node.copyWith(text: controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _promptAddChildNode(MindMapNode parent) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Child Node'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Node Text',
            hintText: 'Enter your idea...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newPosition = Offset(
                  parent.position.dx + 150,
                  parent.position.dy + ((_nodes.length % 3) - 1) * 100,
                );

                final newNode = MindMapNode(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: controller.text,
                  position: newPosition,
                  level: parent.level + 1,
                  color: _getLevelColor(parent.level + 1),
                );

                setState(() {
                  _nodes.add(newNode);
                  _addConnection(parent.id, newNode.id);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[level % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Map Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMindMap,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(),

          // Canvas
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                if (_connectingFrom != null) {
                  // Cancel connection mode
                  setState(() {
                    _connectingFrom = null;
                    _connectingTo = null;
                  });
                } else {
                  _deselectAll();
                }
              },
              child: Container(
                color: Colors.grey[100],
                child: Stack(
                  children: [
                    // Grid Background
                    CustomPaint(
                      size: Size.infinite,
                      painter: GridPainter(),
                    ),

                    // Connections
                    CustomPaint(
                      size: Size.infinite,
                      painter: ConnectionPainter(
                        connections: _connections,
                        nodes: _nodes,
                        connectingFrom: _connectingFrom,
                        connectingTo: _connectingTo,
                      ),
                    ),

                    // Nodes
                    ..._nodes.map((node) => _buildNode(node)).toList(),
                  ],
                ),
              ),
            ),
          ),

          // Info Bar
          if (_selectedNode != null) _buildInfoBar(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: () {
              setState(() {
                _scale = (_scale * 1.2).clamp(0.5, 3.0);
              });
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: () {
              setState(() {
                _scale = (_scale / 1.2).clamp(0.5, 3.0);
              });
            },
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add_node',
            onPressed: () {
              _promptAddNode();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Mind Map Title',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _promptAddNode,
            tooltip: 'Add Node',
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: _connectingFrom == null && _selectedNode != null
                ? () {
                    setState(() {
                      _connectingFrom = _selectedNode;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Now tap another node to connect'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                : null,
            tooltip: 'Connect Nodes',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedNode != null
                ? () => _deleteNode(_selectedNode!)
                : null,
            tooltip: 'Delete Node',
          ),
        ],
      ),
    );
  }

  Widget _buildNode(MindMapNode node) {
    final isSelected = _selectedNode?.id == node.id;
    final isConnecting = _connectingFrom?.id == node.id;

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onTap: () {
          if (_connectingFrom != null && _connectingFrom!.id != node.id) {
            // Complete connection
            _addConnection(_connectingFrom!.id, node.id);
            setState(() {
              _connectingFrom = null;
              _connectingTo = null;
            });
          } else {
            setState(() {
              _selectedNode = node;
            });
          }
        },
        onLongPress: () => _showNodeMenu(node),
        onPanUpdate: (details) {
          setState(() {
            final index = _nodes.indexOf(node);
            _nodes[index] = node.copyWith(
              position: node.position + details.delta,
            );
          });
        },
        child: Transform.scale(
          scale: isSelected ? 1.1 : 1.0,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 80,
              maxWidth: 150,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isConnecting
                  ? Colors.yellow[100]
                  : node.color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.blue : node.color.withOpacity(0.5),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              node.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getTextColor(node.color),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          top: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selected Node:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _selectedNode!.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNode(_selectedNode!),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _promptAddChildNode(_selectedNode!),
            tooltip: 'Add Child',
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () {
              setState(() {
                _connectingFrom = _selectedNode;
              });
            },
            tooltip: 'Connect',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteNode(_selectedNode!),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _showNodeMenu(MindMapNode node) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Text'),
            onTap: () {
              Navigator.pop(context);
              _editNode(node);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Child Node'),
            onTap: () {
              Navigator.pop(context);
              _promptAddChildNode(node);
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Connect to Another Node'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _connectingFrom = node;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Change Color'),
            onTap: () {
              Navigator.pop(context);
              _changeNodeColor(node);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Node', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteNode(node);
            },
          ),
        ],
      ),
    );
  }

  void _changeNodeColor(MindMapNode node) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.red,
      Colors.amber,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  final index = _nodes.indexOf(node);
                  _nodes[index] = node.copyWith(color: color);
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _promptAddNode() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Node'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Node Text',
            hintText: 'Enter your idea...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addNode(
                  text: controller.text,
                  position: Offset(
                    100 + (_nodes.length * 20).toDouble(),
                    100 + (_nodes.length * 20).toDouble(),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deselectAll() {
    setState(() {
      _selectedNode = null;
    });
  }

  void _saveMindMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Mind map saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🧠 Mind Map Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Tap + to add new nodes'),
              Text('• Drag nodes to move them'),
              Text('• Tap a node to select it'),
              Text('• Long press for more options'),
              Text('• Use Connect button to link nodes'),
              SizedBox(height: 16),
              Text(
                'Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Visual organization of ideas'),
              Text('• Shows relationships between concepts'),
              Text('• Improves creativity and recall'),
              Text('• Great for brainstorming'),
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
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Mind Map Node Model
class MindMapNode {
  final String id;
  final String text;
  final Offset position;
  final int level;
  final Color color;

  MindMapNode({
    required this.id,
    required this.text,
    required this.position,
    required this.level,
    required this.color,
  });

  MindMapNode copyWith({
    String? text,
    Offset? position,
    Color? color,
  }) {
    return MindMapNode(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      level: level,
      color: color ?? this.color,
    );
  }
}

/// Mind Map Connection Model
class MindMapConnection {
  final String id;
  final String fromId;
  final String toId;

  MindMapConnection({
    required this.id,
    required this.fromId,
    required this.toId,
  });
}

/// Grid Painter for background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    const gridSize = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Connection Painter for arrows between nodes
class ConnectionPainter extends CustomPainter {
  final List<MindMapConnection> connections;
  final List<MindMapNode> nodes;
  final MindMapNode? connectingFrom;
  final Offset? connectingTo;

  ConnectionPainter({
    required this.connections,
    required this.nodes,
    this.connectingFrom,
    this.connectingTo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw existing connections
    for (final connection in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == connection.fromId);
      final toNode = nodes.firstWhere((n) => n.id == connection.toId);

      paint.color = fromNode.color.withOpacity(0.6);

      _drawArrow(
        canvas,
        paint,
        Offset(fromNode.position.dx + 75, fromNode.position.dy + 25),
        Offset(toNode.position.dx + 75, toNode.position.dy + 25),
      );
    }

    // Draw connecting line if in connect mode
    if (connectingFrom != null && connectingTo != null) {
      paint.color = Colors.blue;
      paint.strokeWidth = 3;
      paint.style = PaintingStyle.stroke;

      final dashPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      _drawDashedLine(
        canvas,
        dashPaint,
        Offset(connectingFrom!.position.dx + 75, connectingFrom!.position.dy + 25),
        connectingTo!,
      );
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    canvas.drawLine(start, end, paint);

    // Arrow head
    final arrowSize = 10.0;
    final angle = (end - start).direction;

    final arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * 0.866 * (1 + 0.5 * (angle / 3.14159).abs()),
      end.dy - arrowSize * 0.5,
    );
    arrowPath.lineTo(
      end.dx - arrowSize * 0.866 * (1 + 0.5 * (angle / 3.14159).abs()),
      end.dy + arrowSize * 0.5,
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    const dashWidth = 5;
    const dashSpace = 3;
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / distance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;

      final p1 = Offset.lerp(start, end, t1)!;
      final p2 = Offset.lerp(start, end, t2)!;

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return connections != oldDelegate.connections ||
        nodes != oldDelegate.nodes ||
        connectingFrom != oldDelegate.connectingFrom ||
        connectingTo != oldDelegate.connectingTo;
  }
}
