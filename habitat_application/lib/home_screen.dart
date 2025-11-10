import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _friends = [
    "Genesis", "Stacy", "Jessica", "Michael", "Mobey", "Soot", "Mudpie",
  ];

  List<String> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _friends;
    _searchController.addListener(_filterFriends);
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase().trim().replaceAll(' ', '');
    setState(() {
      _filteredFriends = _friends.where((friend) {
        final normalizedName = friend.toLowerCase().replaceAll(' ', '');
        return normalizedName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController().isDarkMode,
      builder: (context, darkMode, _) {
        final bgColor = darkMode ? Colors.grey[900] : Colors.white;
        final cardColor = darkMode ? Color(0xFF496C55)! : const Color(0xFFD8E0D0);
        final textColor = darkMode ? Colors.white : Colors.black;
        final secondaryTextColor = darkMode ? Colors.white70 : Colors.white;
        final dottedColor = darkMode ? Color(0xFF344E41) : Color(0xFF344E41);

        return SafeArea(
          child: Container(
            color: bgColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
  
                          Text("Habitat",
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF588157))),
                          Text("Hello, User!",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF588157))),
                        ],
                      ),
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: darkMode ? Colors.grey[800] : Colors.black,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: cardColor,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recents
                  Text("Recents", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _billCard("Houston Trip '25", cardColor, textColor),
                        _billCard("Summer Beach Trip '23", cardColor, textColor),
                        _billCard("Grocery 8/24/23", cardColor, textColor),
                        _billCard("Bill #4", cardColor, textColor),
                        _billCard("Bill #5", cardColor, textColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Friends
                  Text("Friends", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // Search bar
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                    hintStyle: TextStyle(color: secondaryTextColor),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: textColor),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Divider(color: secondaryTextColor),

                          // Friends List
                          SizedBox(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Column(
                                children: _filteredFriends.isEmpty
                                    ? [
                                        const SizedBox(height: 60),
                                        Text("No results found",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: secondaryTextColor)),
                                      ]
                                    : _filteredFriends
                                        .map((friend) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: _friendItem(friend, dottedColor, cardColor, textColor),
                                            ))
                                        .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _billCard(String title, Color cardColor, Color textColor) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      ),
    );
  }

  static Widget _friendItem(String name, Color dottedColor, Color cardColor, Color textColor) {
    return DottedBorder(
      color: dottedColor,
      strokeWidth: 1.2,
      dashPattern: [6, 3],
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: cardColor,
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Color(0xFF496C55), child: Icon(Icons.person, color: Colors.white)),
          title: Text(name, style: TextStyle(color: textColor)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor),
          onTap: () {},
        ),
      ),
    );
  }
}
