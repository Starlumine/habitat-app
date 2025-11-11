import 'package:flutter/material.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final String currentName;
  final IconData? currentAvatar;

  const ProfileUpdateScreen({super.key, required this.currentName, this.currentAvatar});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  late TextEditingController _nameController;
  IconData? _selectedAvatar;

  final List<IconData> _animalIcons = [
    Icons.person,
    Icons.bug_report,
    Icons.flutter_dash,
    Icons.pets,
    Icons.forest,
    Icons.ac_unit,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedAvatar = widget.currentAvatar ?? Icons.person;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAnimalPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: _animalIcons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final icon = _animalIcons[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = icon;
                });
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: Icon(icon, size: 40, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveProfile() {
    Navigator.pop(context, {
      'name': _nameController.text,
      'avatar': _selectedAvatar,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 255, 254),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF496C55),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAnimalPicker,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFA9C6A8),
                child: Icon(
                  _selectedAvatar ?? Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
