// 📍 lib/screens/profile_feed_screen.dart (신규 파일)

import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/widgets/post_widget.dart';

class ProfileFeedScreen extends StatefulWidget {
  final List<PostModel> posts; // 전체 게시물 리스트
  final int initialIndex; // 처음에 보여줄 게시물 번호
  final String username; // 상단에 띄울 이름

  const ProfileFeedScreen({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.username,
  });

  @override
  State<ProfileFeedScreen> createState() => _ProfileFeedScreenState();
}

class _ProfileFeedScreenState extends State<ProfileFeedScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // ⭐️ 선택한 사진 위치로 스크롤 이동 (대략적인 높이 계산: 게시물 하나당 약 600px)
    // 정확한 위치는 아니지만, 해당 게시물 근처로 이동합니다.
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialIndex * 650.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(), // 뒤로 가기
        ),
        title: Column(
          children: [
            Text(
              widget.username.toUpperCase(),
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'Posts',
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      // ⭐️ 홈 화면과 똑같은 PostWidget을 사용하여 데이터 공유
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          return PostWidget(post: widget.posts[index]);
        },
      ),
    );
  }
}
