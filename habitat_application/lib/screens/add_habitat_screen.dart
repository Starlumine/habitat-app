import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_detail_screen.dart';

class HabitatHomePage extends StatefulWidget {
  const HabitatHomePage({super.key});

  @override
  State<HabitatHomePage> createState() => _HabitatHomePageState();
}

class _HabitatHomePageState extends State<HabitatHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();
  final CollectionReference habitatsCollection =
      FirebaseFirestore.instance.collection('habitats');

  void _createHabitat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Habitat'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter Habitat name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  try {
                    // Add habitat to Firestore
                    final docRef = await habitatsCollection.add({
                      'name': name,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    
                    // Add creator as first member
                    await habitatsCollection
                        .doc(docRef.id)
                        .collection('members')
                        .add({
                      'joinedAt': FieldValue.serverTimestamp(),
                    });
                    
                    _nameController.clear();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating habitat: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _deleteHabitat(String docId) {
    habitatsCollection.doc(docId).delete();
  }

  Future<void> _joinGroup() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Habitat'),
          content: TextField(
            controller: _joinCodeController,
            decoration: const InputDecoration(
              hintText: 'Enter habitat code',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vpn_key),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _joinCodeController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final code = _joinCodeController.text.trim();
                if (code.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a group code'),
                    ),
                  );
                  return;
                }

                try {
                  // Check if group exists
                  final groupDoc = await habitatsCollection.doc(code).get();
                  
                  if (!groupDoc.exists) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Habitat not found. Please check the code.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  // Get group data
                  final groupData = groupDoc.data() as Map<String, dynamic>;
                  final groupName = groupData['name'] ?? 'Unknown Group';

                  // Add member to group (using a members subcollection)
                  await habitatsCollection
                      .doc(code)
                      .collection('members')
                      .add({
                    'joinedAt': FieldValue.serverTimestamp(),
                  });

                  _joinCodeController.clear();
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully joined $groupName!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Navigate to the group detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailScreen(
                          groupId: code,
                          groupName: groupName,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error joining habitat: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Habitats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createHabitat,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Habitat'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _joinGroup,
                    icon: const Icon(Icons.login),
                    label: const Text('Join Habitat'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: habitatsCollection.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No habitats yet. Create one to get started!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final name = doc['name'];
                    return ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(name),
                      onTap: () {
                        // Navigate to group detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailScreen(
                              groupId: doc.id,
                              groupName: name,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteHabitat(doc.id),
                      ),
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
}

