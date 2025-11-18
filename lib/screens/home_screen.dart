import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:instagram/screens/dm_list_screen.dart';

class HomeScreen extends StatelessWidget {
  // ⭐️ 2. "중앙 포스트 리스트"를 전달받을 그릇
  final List<Map<String, dynamic>> allPosts;

  const HomeScreen({
    super.key,
    required this.allPosts, // ⭐️ 3. 필수로 받도록 수정
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          // ⭐️ 4. PNG 로고 사용 (기존 코드)
          'assets/images/ic_instagram_logo.png',
          height: 32,
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.heart),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.paperplane),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DmListScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        // ⭐️ 5. 가짜 갯수(5) 대신, 실제 리스트의 길이만큼
        itemCount: allPosts.length,
        itemBuilder: (context, index) {
          // ⭐️ 6. 리스트의 index번째 데이터를 PostWidget에 전달
          // ⭐️ (리스트가 역순으로 보이도록 (최신순))
          final postData = allPosts[allPosts.length - 1 - index];
          return PostWidget(postData: postData);
        },
      ),
    );
  }
}
