import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Earthy color palette for status indicators
class EarthyColors {
  // Expired/Error states - muted brown-red
  static const Color expiredLight = Color(0xFFD4A574); // Light terracotta
  static const Color expiredDark = Color(0xFF8B5A3C); // Dark terracotta
  
  // Expires soon/Warning - warm amber-brown
  static const Color warningLight = Color(0xFFD4B896); // Light amber
  static const Color warningDark = Color(0xFF9D7A5A); // Dark amber
  
  // Runoff/Info - muted sage green
  static const Color infoLight = Color(0xFFB8C5A3); // Light sage
  static const Color infoDark = Color(0xFF6B7D5A); // Dark sage
  
  // Delete/Actions - muted rust
  static const Color delete = Color(0xFFA67C5A); // Muted rust brown
}

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  DateTime? _selectedExpirationDate;
  TimeOfDay? _selectedExpirationTime;
  int _currentIndex = 0;

  @override
  void dispose() {
    _pollQuestionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.groupName),
      ),
      body: _getCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: 'Polls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Invite',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _getCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildPollsTab();
      case 1:
        return _buildMembersTab();
      case 2:
        return _buildInviteTab();
      default:
        return _buildPollsTab();
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    if (_currentIndex == 0) {
      // Show FAB only on Polls tab
      return FloatingActionButton(
        onPressed: () => _showCreatePollDialog(context),
        backgroundColor: const Color(0xFF588157), // Medium green from theme
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Create Poll',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPollsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('habitats')
          .doc(widget.groupId)
          .collection('polls')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final polls = snapshot.data!.docs;

        if (polls.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.poll,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No polls yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to create a poll',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Check for expired polls with ties and create runoff polls
        for (final poll in polls) {
          final pollData = poll.data() as Map<String, dynamic>;
          final expiresAt = pollData['expiresAt'] as Timestamp?;
          final hasRunoff = pollData['runoffCreated'] as bool? ?? false;
          final isRunoff = pollData['isRunoff'] as bool? ?? false;
          
          if (expiresAt != null && 
              expiresAt.toDate().isBefore(DateTime.now()) && 
              !hasRunoff && 
              !isRunoff) {
            _checkAndCreateRunoffPoll(poll);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return _buildPollCard(poll);
          },
        );
      },
    );
  }

  Widget _buildPollCard(DocumentSnapshot poll) {
    final data = poll.data() as Map<String, dynamic>;
    final question = data['question'] ?? '';
    final options = List<String>.from(data['options'] ?? []);
    final votes = Map<String, int>.from(data['votes'] ?? {});
    final createdAt = data['createdAt'] as Timestamp?;
    final expiresAt = data['expiresAt'] as Timestamp?;
    final isRunoff = data['isRunoff'] as bool? ?? false;

    // Check if poll is expired
    final isExpired = expiresAt != null && 
                      expiresAt.toDate().isBefore(DateTime.now());

    // Calculate total votes
    final totalVotes = votes.values.fold(0, (sum, count) => sum + count);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRunoff)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: EarthyColors.infoLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Runoff Poll',
                              style: TextStyle(
                                fontSize: 11,
                                color: EarthyColors.infoDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: EarthyColors.delete),
                  onPressed: () => _showDeletePollDialog(context, poll.id, question),
                  tooltip: 'Delete Poll',
                ),
              ],
            ),
            if (isExpired || expiresAt != null || (createdAt != null && !isExpired && expiresAt == null))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: EarthyColors.expiredLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 14, color: EarthyColors.expiredDark),
                            const SizedBox(width: 4),
                            Text(
                              'Expired',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: EarthyColors.expiredDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (expiresAt != null)
                      InkWell(
                        onTap: isRunoff && !isExpired
                            ? () => _showEditExpirationDialog(context, poll.id, expiresAt.toDate())
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: EarthyColors.warningLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 14, color: EarthyColors.warningDark),
                              const SizedBox(width: 4),
                              Text(
                                'Expires ${_formatExpirationDate(expiresAt.toDate())}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: EarthyColors.warningDark,
                                ),
                              ),
                              if (isRunoff && !isExpired) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.edit, size: 12, color: EarthyColors.warningDark),
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (createdAt != null && !isExpired && expiresAt == null)
                      Text(
                        _formatDate(createdAt.toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final voteCount = votes[optionIndex.toString()] ?? 0;
              final percentage = totalVotes > 0 ? (voteCount / totalVotes) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: isExpired ? null : () => _voteOnPoll(poll.id, optionIndex),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isExpired ? Colors.grey[400]! : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isExpired ? Colors.grey[100] : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isExpired ? Colors.grey[600] : null,
                                ),
                              ),
                            ),
                            if (totalVotes > 0 || isExpired)
                              Text(
                                totalVotes > 0
                                    ? '${(percentage * 100).toStringAsFixed(0)}%'
                                    : '0%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (totalVotes > 0 || isExpired)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[200],
                          minHeight: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isExpired ? Colors.grey[400]! : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    if (totalVotes > 0 || isExpired)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$voteCount vote${voteCount != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total votes: $totalVotes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (isExpired)
                  Text(
                    'Results Final',
                    style: TextStyle(
                      fontSize: 12,
                      color: EarthyColors.expiredDark,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('habitats')
                  .doc(widget.groupId)
                  .collection('members')
                  .orderBy('joinedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = snapshot.data!.docs;

                if (members.isEmpty) {
                  return Center(
                    child: Text(
                      'No members yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final joinedAt = member['joinedAt'] as Timestamp?;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      title: const Text('Anonymous Member'),
                      subtitle: joinedAt != null
                          ? Text(
                              'Joined ${_formatDate(joinedAt.toDate())}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Invite People',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Share this code with others to join your group:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Group Code Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.groupId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.groupId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Group code copied to clipboard!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Invite Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showInviteDialog(context);
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Invite People'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePollDialog(BuildContext context) {
    // Reset controllers
    _pollQuestionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    // Ensure at least 2 options
    while (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
    }
    // Reset expiration
    _selectedExpirationDate = null;
    _selectedExpirationTime = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Poll'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _pollQuestionController,
                      decoration: const InputDecoration(
                        labelText: 'Poll Question',
                        hintText: 'What should we decide?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Options:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._optionControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                            suffixIcon: _optionControllers.length > 2
                                ? IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () {
                                      setDialogState(() {
                                        _optionControllers[index].dispose();
                                        _optionControllers.removeAt(index);
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                    if (_optionControllers.length < 6)
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            _optionControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Option'),
                      ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Expiration (Optional):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                setDialogState(() {
                                  _selectedExpirationDate = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedExpirationDate == null
                                  ? 'Select Date'
                                  : '${_selectedExpirationDate!.month}/${_selectedExpirationDate!.day}/${_selectedExpirationDate!.year.toString().substring(2)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                setDialogState(() {
                                  _selectedExpirationTime = pickedTime;
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _selectedExpirationTime == null
                                  ? 'Select Time'
                                  : _selectedExpirationTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedExpirationDate != null || _selectedExpirationTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              _selectedExpirationDate = null;
                              _selectedExpirationTime = null;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Expiration'),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final question = _pollQuestionController.text.trim();
                    final options = _optionControllers
                        .map((c) => c.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList();

                    if (question.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a question'),
                          backgroundColor: EarthyColors.expiredDark,
                        ),
                      );
                      return;
                    }

                    if (options.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please add at least 2 options'),
                          backgroundColor: EarthyColors.expiredDark,
                        ),
                      );
                      return;
                    }

                    try {
                      // Calculate expiration timestamp if date/time are selected
                      Timestamp? expirationTimestamp;
                      if (_selectedExpirationDate != null) {
                        DateTime expirationDateTime = _selectedExpirationDate!;
                        if (_selectedExpirationTime != null) {
                          expirationDateTime = DateTime(
                            _selectedExpirationDate!.year,
                            _selectedExpirationDate!.month,
                            _selectedExpirationDate!.day,
                            _selectedExpirationTime!.hour,
                            _selectedExpirationTime!.minute,
                          );
                        } else {
                          // If date but no time, set to end of day
                          expirationDateTime = DateTime(
                            _selectedExpirationDate!.year,
                            _selectedExpirationDate!.month,
                            _selectedExpirationDate!.day,
                            23,
                            59,
                          );
                        }
                        expirationTimestamp = Timestamp.fromDate(expirationDateTime);
                      }

                      // Create poll in Firestore
                      final pollData = {
                        'question': question,
                        'options': options,
                        'votes': <String, int>{},
                        'createdAt': FieldValue.serverTimestamp(),
                      };
                      
                      if (expirationTimestamp != null) {
                        pollData['expiresAt'] = expirationTimestamp;
                      }

                      await FirebaseFirestore.instance
                          .collection('habitats')
                          .doc(widget.groupId)
                          .collection('polls')
                          .add(pollData);

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Poll created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating poll: $e'),
                            backgroundColor: EarthyColors.expiredDark,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _voteOnPoll(String pollId, int optionIndex) async {
    try {
      final pollRef = FirebaseFirestore.instance
          .collection('habitats')
          .doc(widget.groupId)
          .collection('polls')
          .doc(pollId);

      // Use FieldValue.increment to atomically increment the vote count
      await pollRef.update({
        'votes.$optionIndex': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote recorded!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error voting: $e'),
            backgroundColor: EarthyColors.expiredDark,
          ),
        );
      }
    }
  }

  void _showDeletePollDialog(BuildContext context, String pollId, String question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Poll'),
          content: Text(
            'Are you sure you want to delete this poll?\n\n"$question"\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePoll(pollId);
              },
              style: TextButton.styleFrom(
                foregroundColor: EarthyColors.delete,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePoll(String pollId) async {
    try {
      await FirebaseFirestore.instance
          .collection('habitats')
          .doc(widget.groupId)
          .collection('polls')
          .doc(pollId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting poll: $e'),
            backgroundColor: EarthyColors.expiredDark,
          ),
        );
      }
    }
  }

  void _showEditExpirationDialog(BuildContext context, String pollId, DateTime currentExpiration) {
    DateTime? selectedDate = currentExpiration;
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(currentExpiration);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Poll Expiration'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set new expiration date and time:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                setDialogState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year.toString().substring(2)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                setDialogState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              selectedTime == null
                                  ? 'Select Time'
                                  : selectedTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select both date and time'),
                          backgroundColor: EarthyColors.expiredDark,
                        ),
                      );
                      return;
                    }

                    final expirationDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    if (expirationDateTime.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Expiration time must be in the future'),
                          backgroundColor: EarthyColors.expiredDark,
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('habitats')
                          .doc(widget.groupId)
                          .collection('polls')
                          .doc(pollId)
                          .update({
                        'expiresAt': Timestamp.fromDate(expirationDateTime),
                      });

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Expiration time updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating expiration: $e'),
                            backgroundColor: EarthyColors.expiredDark,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _checkAndCreateRunoffPoll(DocumentSnapshot poll) async {
    try {
      // Re-fetch the poll to ensure we have the latest data
      final pollDoc = await poll.reference.get();
      if (!pollDoc.exists) return;
      
      final data = pollDoc.data() as Map<String, dynamic>;
      
      // Double-check that runoff hasn't been created yet
      if (data['runoffCreated'] == true) {
        return;
      }
      
      final options = List<String>.from(data['options'] ?? []);
      final votes = Map<String, int>.from(data['votes'] ?? {});
      final question = data['question'] ?? '';
      
      if (options.isEmpty) {
        return;
      }

      // Get vote counts for each option
      final voteCounts = <int, int>{};
      for (int i = 0; i < options.length; i++) {
        voteCounts[i] = votes[i.toString()] ?? 0;
      }

      // Find the maximum vote count
      if (voteCounts.isEmpty || voteCounts.values.every((count) => count == 0)) {
        return; // No votes, no tie
      }
      
      final maxVotes = voteCounts.values.reduce((a, b) => a > b ? a : b);
      
      // Find all options with the maximum vote count
      final topOptions = <int>[];
      voteCounts.forEach((index, count) {
        if (count == maxVotes) {
          topOptions.add(index);
        }
      });

      // If there's a tie (2 or more options with the same max votes)
      if (topOptions.length >= 2) {
        // Get the top two options (or all if exactly 2)
        final runoffOptions = topOptions.take(2).toList();
        final runoffOptionTexts = runoffOptions.map((index) => options[index]).toList();

        // Use a transaction to prevent race conditions
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final pollRef = pollDoc.reference;
          final pollSnapshot = await transaction.get(pollRef);
          
          final snapshotData = pollSnapshot.data() as Map<String, dynamic>?;
          if (snapshotData?['runoffCreated'] == true) {
            return; // Runoff already created
          }
          
          // Create runoff poll with default expiration of 7 days
          final runoffPollRef = FirebaseFirestore.instance
              .collection('habitats')
              .doc(widget.groupId)
              .collection('polls')
              .doc();
          
          final defaultExpiration = DateTime.now().add(const Duration(days: 7));
          
          transaction.set(runoffPollRef, {
            'question': '$question (Runoff)',
            'options': runoffOptionTexts,
            'votes': <String, int>{},
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': Timestamp.fromDate(defaultExpiration),
            'isRunoff': true,
            'originalPollId': poll.id,
          });
          
          // Mark original poll as having a runoff created
          transaction.update(pollRef, {
            'runoffCreated': true,
          });
        });
      }
    } catch (e) {
      // Silently handle errors to avoid disrupting the UI
      debugPrint('Error creating runoff poll: $e');
    }
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invite People'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share this group code with others:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  widget.groupId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'They can join by entering this code in the app.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatExpirationDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      // If less than a minute, show the actual date/time
      return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

}

