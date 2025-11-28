import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/widgets/post_widget.dart';

class ProfileFeedScreen extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;
  final String username;

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
    // 선택한 사진 위치로 대략 이동 (게시물 높이 약 600px 추정)
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialIndex * 600.0,
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
          onPressed: () => Navigator.of(context).pop(),
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
