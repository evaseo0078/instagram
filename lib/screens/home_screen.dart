import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart'; // 모델 import
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/widgets/post_widget.dart';

class HomeScreen extends StatelessWidget {
  // ⭐️ List<Map> -> List<PostModel> 변경
  final List<PostModel> allPosts;

  const HomeScreen({
    super.key,
    required this.allPosts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
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
        itemCount: allPosts.length,
        itemBuilder: (context, index) {
          // 최신순 정렬 (역순)
          final post = allPosts[allPosts.length - 1 - index];
          return PostWidget(post: post); // ⭐️ PostModel 전달
        },
      ),
    );
  }
}
