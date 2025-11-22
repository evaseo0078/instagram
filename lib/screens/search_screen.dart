import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // 데이터
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/utils/colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data에서 내 계정을 제외한 모든 유저 리스트 생성
    final otherUsers = MOCK_USERS.values
        .where((user) => user.username != 'ta_junhyuk')
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 검색창
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                backgroundColor: Colors.grey[200],
                placeholder: 'Search',
                style: const TextStyle(color: primaryColor),
              ),
            ),
            // 유저 리스트
            Expanded(
              child: ListView.builder(
                itemCount: otherUsers.length,
                itemBuilder: (context, index) {
                  final user = otherUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(user.profilePicAsset),
                    ),
                    title: Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.name,
                        style: const TextStyle(color: secondaryColor)),
                    trailing: const Icon(Icons.close,
                        size: 16, color: secondaryColor),
                    onTap: () {
                      // ⭐️ 해당 유저의 프로필로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
