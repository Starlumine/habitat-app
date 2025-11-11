// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
  
import 'screens/receipt_split_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'theme_controller.dart'; // for syncing dark mode across all screens

// void main() {
//   runApp(const MyApp());
// }


import 'package:flutter/material.dart';
import 'messaging.dart';  // Make sure this path is correct


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 2; // Home in the middle

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HabitatHomePage(),
      const ChatApp(),
      const HomePage(),
      const ReceiptSplitScreen(),
      const ProfileScreen(),
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController().isDarkMode,
      builder: (context, darkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: darkMode ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(
            backgroundColor: darkMode ? Colors.black : Colors.white,
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: darkMode ? Colors.grey[900] : const Color(0xFF496C55),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.poll_outlined), label: 'Polls'),
                const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkMode ? Color(0xFFA9C6A8): Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.home,
                      color: darkMode ? Colors.white : const Color(0xFF496C55),
                      size: 30,
                    ),
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Bills'),
                const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),

          ),
        );
      },
    );
  }
}
