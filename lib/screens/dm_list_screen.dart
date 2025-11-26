// 📍 lib/screens/dm_list_screen.dart (전체 덮어쓰기)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/chat_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/data/chat_data.dart';
import 'package:instagram/models/chat_message.dart';

class DmListScreen extends StatefulWidget {
  const DmListScreen({super.key});

  @override
  State<DmListScreen> createState() => _DmListScreenState();
}

class _DmListScreenState extends State<DmListScreen> {
  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) {
      return "${diff.inDays}d ago";
    } else if (diff.inHours > 0) {
      return "${diff.inHours}h ago";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes}m ago";
    } else {
      return "now";
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUser = MOCK_USERS['brown']!;

    List<Map<String, dynamic>> dmList = [];
    final targetUsers = ['inseong', 'conan'];

    for (var userId in targetUsers) {
      final user = MOCK_USERS[userId]!;
      final messages = ChatData.getMessages(user.name);

      if (messages.isNotEmpty) {
        final lastMsg = messages.first;
        dmList.add({
          "user": user,
          "lastMessage": lastMsg.text,
          "isSeen": lastMsg.status == MessageStatus.seen,
          "isSentByMe": lastMsg.isSentByMe, // ⭐️ 누가 보냈는지 확인
          "timestamp": lastMsg.timestamp,
          "timeString": _formatTime(lastMsg.timestamp),
        });
      }
    }

    dmList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              myUser.username,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 20, color: primaryColor),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon:
                const Icon(CupertinoIcons.pencil_outline, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Search',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: const Text(
                        "What's on\nyour playlist?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11, color: Colors.black87, height: 1.2),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage(myUser.profilePicAsset),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_circle,
                              color: Colors.grey, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Your note",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text('Messages',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(CupertinoIcons.bell_slash,
                        size: 16, color: secondaryColor),
                  ],
                ),
                const Text('Requests (1)',
                    style: TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
          ),
          ...dmList.map((dm) {
            final UserModel user = dm['user'];
            final String lastMessage = dm['lastMessage'];
            final String timeString = dm['timeString'];
            final bool isSentByMe = dm['isSentByMe']; // 내가 보낸건지 확인
            final bool isSeen = dm['isSeen']; // 상대가 읽었는지(Seen) 확인

            String subtitleText;

            // ⭐️ 메시지 상태 로직 수정 (Ran: Seen / Kid: Sent 3m ago)
            if (isSentByMe) {
              // 내가 보낸 경우
              if (isSeen) {
                subtitleText = "Seen"; // 시간 표시 안 함
              } else {
                subtitleText = "Sent $timeString"; // Sent 3m ago
              }
            } else {
              // 상대가 보낸 경우 (메시지 내용 + 시간)
              subtitleText =
                  "${lastMessage.length > 20 ? lastMessage.substring(0, 20) + '...' : lastMessage} · $timeString";
            }

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(user.profilePicAsset),
              ),
              title: Text(user.name, style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                subtitleText,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14,
                ),
              ),
              trailing: const Icon(CupertinoIcons.camera,
                  color: secondaryColor, size: 26),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      username: user.name,
                      profilePicAsset: user.profilePicAsset,
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
            );
          }).toList(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text("Find friends to follow and message",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          _buildFindFriendsItem(Icons.contacts, "Connect contacts",
              "Follow people you know.", "Connect"),
          _buildFindFriendsItem(Icons.search, "Search for friends",
              "Find your friends' accounts.", "Search"),
        ],
      ),
    );
  }

  Widget _buildFindFriendsItem(
      IconData icon, String title, String subtitle, String btnText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black54, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: Text(btnText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.close, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
