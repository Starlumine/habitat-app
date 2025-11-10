import 'package:flutter/material.dart';
import 'profile_update.dart';
import 'theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "NAME";
  IconData userAvatar = Icons.person;

  final Color midGreen = const Color(0xFFA9C6A8);
  final Color darkGreen = const Color(0xFF496C55);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController().isDarkMode,
      builder: (context, darkMode, _) {
        final bgColor = darkMode ? Colors.black : Colors.white;
        final headerColor = darkMode ? darkGreen : darkGreen;
        final cardColor = darkMode ? Colors.grey[900]! : Colors.white;
        final sectionColor = darkMode ? darkGreen : darkGreen;
        final textColor = darkMode ? Colors.white : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // Header
              Container(height: 180, color: headerColor),

              // Avatar
              Positioned(
                top: 100,
                left: 20,
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: darkMode ? Colors.grey[700] : Colors.white,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: midGreen,
                    child: Icon(userAvatar, color: Colors.white, size: 60),
                  ),
                ),
              ),

              // Name & Edit Button
              Positioned(
                top: 210,
                left: 42,
                right: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileUpdateScreen(
                              currentName: userName,
                              currentAvatar: userAvatar,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            userName = result['name'];
                            if (result['avatar'] != null) {
                              userAvatar = result['avatar'];
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: midGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(color: darkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Padding(
                padding: const EdgeInsets.only(top: 250),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSection(
                          title: "Account",
                          children: const [
                            "Email: user@gmail.com",
                            "Password: *********",
                            "Phone: +1 234 567 8901",
                            "Gender: Female",
                          ],
                          sectionColor: sectionColor,
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          title: "Settings",
                          children: const ["Dark Mode", "Notifications"],
                          switchIndex: 0,
                          sectionColor: sectionColor,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> children,
    int? switchIndex,
    required Color sectionColor,
  }) {
    final textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: sectionColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) _buildDivider(),
              const SizedBox(height: 8),
              (switchIndex != null && i == switchIndex)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(children[i], style: TextStyle(color: textColor)),
                        Switch(
                          value: ThemeController().isDarkMode.value,
                          onChanged: (_) => ThemeController().toggle(),
                          activeThumbColor: Colors.black,
                          activeTrackColor: const Color(0xFFA9C6A8),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(children[i], style: TextStyle(color: textColor)),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(height: 1, color: Colors.black26);
}
