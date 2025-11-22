import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/utils/colors.dart';

class FollowingListScreen extends StatelessWidget {
  final List<String> followingUsernames; // 내가 팔로우하는 사람들의 ID 리스트

  const FollowingListScreen({super.key, required this.followingUsernames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: followingUsernames.length,
        itemBuilder: (context, index) {
          final username = followingUsernames[index];
          final user = MOCK_USERS[username]; // ID로 유저 정보 찾기

          if (user == null) return const SizedBox.shrink(); // 없으면 빈칸

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(user.profilePicAsset),
            ),
            title: Text(user.username,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.name),
            // trailing: OutlinedButton(
            //   onPressed: () {},
            //   child: const Text('Following',
            //       style: TextStyle(color: primaryColor)),
            // ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: secondaryColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('Following',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            onTap: () {
              // ⭐️ 누르면 그 사람 프로필로 이동 (영상 기능)
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user)),
              );
            },
          );
        },
      ),
    );
  }
}
