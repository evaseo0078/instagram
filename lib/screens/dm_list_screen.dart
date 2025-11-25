// 📍 lib/screens/dm_list_screen.dart (전체 수정)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // ⭐️ 데이터 연동
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/chat_screen.dart';
import 'package:instagram/utils/colors.dart';

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 내 정보 (brown 박사님)
    final myUser = MOCK_USERS['brown']!;

    // ⭐️ DM 리스트 데이터 (MOCK_USERS와 연동 및 순서 정렬)
    // 1. kid_go (3m ago) - 위쪽
    // 2. ran (Seen) - 아래쪽
    final List<Map<String, dynamic>> dmList = [
      {
        "user": MOCK_USERS['kid_go'], // 실제 유저 객체 연결
        "lastMessage": "Sent 3m ago",
        "isSeen": false, // 내가 보낸 메시지 (검정색)
        "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      },
      {
        "user": MOCK_USERS['ran'],
        "lastMessage": "Seen",
        "isSeen": true, // 읽음 처리됨 (회색)
        "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
      },
    ];

    // ⭐️ 시간 순서대로 정렬 (최신순: timestamp가 큰 게 위로)
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
        // ⭐️ 1. 내 아이디 변경 (ph.brown)
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              myUser.username, // "ph.brown"
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
          // 검색창
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

          // ⭐️ 2. Note (말풍선 위치 조정)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Column(
                  children: [
                    // 말풍선
                    Container(
                      // ⭐️ 간격을 2로 줄여서 프로필 사진과 더 가깝게 붙임
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20), // 더 둥글게
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
                    // 내 프로필 사진 + 플러스 아이콘
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 32, // 사진 크기 약간 키움
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

          // ⭐️ 5. Messages 헤더 + 벨 아이콘 추가
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
                    // ⭐️ 벨 울림 안됨 아이콘
                    Icon(CupertinoIcons.bell_slash,
                        size: 16, color: secondaryColor),
                  ],
                ),
                const Text('Requests (1)',
                    style: TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
          ),

          // ⭐️ 3 & 4. 메시지 리스트 (데이터 연동 + 순서 변경)
          ...dmList.map((dm) {
            final UserModel user = dm['user']; // UserModel 객체
            final String lastMessage = dm['lastMessage'];
            final bool isSeen = dm['isSeen'];

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: CircleAvatar(
                radius: 26,
                backgroundImage:
                    AssetImage(user.profilePicAsset), // ⭐️ 실제 프로필 사진
              ),
              title: Text(user.name,
                  style:
                      const TextStyle(fontSize: 14)), // ⭐️ 실제 이름 (Kaito Kid 등)
              subtitle: Text(
                lastMessage,
                style: TextStyle(
                  color: isSeen ? secondaryColor : primaryColor, // Seen은 회색
                  fontSize: 14,
                  fontWeight: isSeen ? FontWeight.normal : FontWeight.w500,
                ),
              ),
              trailing: const Icon(CupertinoIcons.camera,
                  color: secondaryColor, size: 26),
              onTap: () {
                // 채팅방으로 이동 (데이터 전달)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      username: user.name, // 채팅방 제목
                      profilePicAsset: user.profilePicAsset,
                    ),
                  ),
                );
              },
            );
          }).toList(),

          // 하단 친구 추천 섹션
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

  // ⭐️ 6. 버튼 가로 길이 통일
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
          // ⭐️ SizedBox로 감싸서 버튼 너비 고정
          SizedBox(
            width: 90, // 가로 길이 통일
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero, // 패딩 제거 (SizedBox로 크기 잡음)
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
