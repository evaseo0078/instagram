import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/chat_screen.dart'; // ⭐️ ChatScreen import 필수
import 'package:instagram/utils/colors.dart';

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  // 가짜 DM 리스트
  final List<Map<String, String>> _dmList = const [
    {
      "username": "shinichi",
      "lastMessage": "Seen",
      "assetImage": "assets/images/profiles/shinichi.png"
    },
    {
      "username": "kid_go",
      "lastMessage": "Sent 3m ago",
      "assetImage": "assets/images/profiles/kid_go.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            const Text('Direct', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(CupertinoIcons.video_camera), onPressed: () {}),
          IconButton(
              icon: const Icon(CupertinoIcons.plus_app), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CupertinoSearchTextField(
              backgroundColor: Colors.grey[900],
              style: const TextStyle(color: primaryColor),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Messages',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ..._dmList.map((dm) {
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(dm['assetImage']!),
              ),
              title: Text(dm['username']!),
              subtitle: Text(dm['lastMessage']!,
                  style: const TextStyle(color: secondaryColor)),
              trailing:
                  const Icon(CupertinoIcons.camera, color: secondaryColor),
              onTap: () {
                // ⭐️ ChatScreen으로 이동 (오류 해결)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      username: dm['username']!,
                      profilePicAsset: dm['assetImage']!,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
