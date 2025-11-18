// 📍 lib/screens/dm_list_screen.dart (신규 파일)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/chat_screen.dart'; // ⭐️ 3단계에서 만들 파일
import 'package:instagram/utils/colors.dart';

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  // ⭐️ 2단계에서 만들 가짜 계정 데이터를 여기에 넣을 수 있습니다.
  // (지금은 간단하게 하드코딩)
  final List<Map<String, String>> _dmList = const [
    {
      "username": "신해빈",
      "lastMessage": "Seen",
      "assetImage": "assets/images/haebin_profile.png"
    },
    {
      "username": "최준혁",
      "lastMessage": "Sent 3m ago",
      "assetImage": "assets/images/junhyuk_profile.png"
    },
    // ... (더 많은 가짜 DM)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('ta_junhyuk',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.video_camera, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.plus_app, color: primaryColor),
            onPressed: () {},
          ),
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
          // ⭐️ 가짜 DM 리스트
          ..._dmList.map((dm) {
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                // ⭐️ 2번 항목에서 만들 Asset 이미지를 사용합니다.
                // ⭐️ 만약 이미지가 없다면, 일단 아이콘으로 대체하세요.
                backgroundImage: AssetImage(dm['assetImage']!),
                onBackgroundImageError: (exception, stackTrace) {
                  // (이미지 로드 실패 시 임시 아이콘)
                },
                child: !dm['assetImage']!.contains('assets/')
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(dm['username']!),
              subtitle: Text(dm['lastMessage']!,
                  style: const TextStyle(color: secondaryColor)),
              trailing:
                  const Icon(CupertinoIcons.camera, color: secondaryColor),
              onTap: () {
                // ⭐️ 3단계에서 만들 ChatScreen으로 이동
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
