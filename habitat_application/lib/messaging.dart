import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GroupListScreen(),
    );
  }
}

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  List<Map<String, dynamic>> groups = [
    {'name': 'Roommates', 'type': 'clowder', 'unread': 2, 'icon': Icons.pets},
    {'name': 'Besties', 'type': 'smack', 'unread': 0, 'icon': Icons.group},
    {'name': 'Family', 'type': 'romp', 'unread': 0, 'icon': Icons.home},
  ];

  void openChat(String groupName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(groupName: groupName)),
    );

    setState(() {
      final index = groups.indexWhere((g) => g['name'] == groupName);
      if (index != -1) groups[index]['unread'] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top green section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF588157), // full green background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                // Elevated circular plus button
                Material(
                  color: Colors.white, // button background
                  shape: const CircleBorder(),
                  elevation: 6, // shadow to pop out
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(12), // button size
                      child: Icon(
                        Icons.add,
                        color: Color(0xFF9BAE94), // green icon
                        size: 28, // bigger icon
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 12), // spacing between top section and list

          // Group chat list
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Column(
                children: [
                    GroupTile(
                    title: group['name']!,
                    subtitle: group['type']!,
                    unread: group['unread'],
                    icon: group['icon'],
                    onTap: () => openChat(group['name']!),
                ),
                //Light grey separator Line
                Divider(
                  color:Colors.grey.shade300,
                  thickness:1,
                  height:1, 
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      )
    );
  }
}

class GroupTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int unread;
  final IconData icon;
  final VoidCallback onTap;

  const GroupTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unread,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF9BAE94),
            child: Icon(icon, color: Colors.white),
          ),
          if (unread > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unread.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          Text('($subtitle)', style: const TextStyle(fontStyle: FontStyle.italic)),
      onTap: onTap,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String groupName;
  const ChatScreen({super.key, required this.groupName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Each chat has its own message list
  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();

    if (widget.groupName == 'Roommates') {
      messages = [
        {
          'text': 'Hi guys!!',
          'isMe': false,
          'color': const Color(0xFFA3B18A)
        },
        {
          'text': 'Hiii',
          'isMe': false,
          'color': const Color(0xFF3A5A40)
        },
        {
          'text': 'Heyyyy',
          'isMe': true,
          'color': const Color(0xFFDAD7CD)
        },
        {
          'text': 'This app is pretty cool',
          'isMe': false,
          'color': const Color(0xFF588157) // optional, or keep white for right
        },
        {
          'text': 'ikr',
          'isMe': false,
          'color': const Color(0xFFA3B18A)
        },
      ];
    } else {
      messages = [];
    }
  }

  void sendMessage() {
  if (_controller.text.trim().isEmpty) return;

  setState(() {
    messages.add({'text': _controller.text.trim(), 'isMe': true}); // you are 'isMe' = true
  });

  _controller.clear();

  // Scroll to bottom
  Future.delayed(const Duration(milliseconds: 100), () {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: const Color(0xFFA3B18A),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('No messages yet...',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        text: msg['text']!,
                        isMe: msg['isMe']!,
                        color: msg.containsKey('color') ? msg['color'] : null,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFEAE5D9),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Text Here...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFEAE5D9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF9BAE94),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final Color? color;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.white : color ?? const Color(0xFF6B7B5E),
          borderRadius: BorderRadius.circular(12),
          border: isMe ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.black : Colors.white,
            fontFamily: 'ComicSans',
          ),
        ),
      ),
    );
  }
}
