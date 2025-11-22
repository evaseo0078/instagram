import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // 데이터 접근용
import 'package:instagram/models/post_model.dart'; // 모델 import
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/screens/profile_screen.dart'; // 프로필 이동용
import 'package:instagram/utils/colors.dart';

class PostWidget extends StatefulWidget {
  final PostModel post; // ⭐️ Map -> PostModel로 변경

  const PostWidget({
    super.key,
    required this.post,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isBigHeartVisible = false;

  // ⭐️ 좋아요 더블 탭
  void _handleDoubleTapLike() {
    setState(() {
      widget.post.isLiked = true;
      widget.post.likes++;
      _isBigHeartVisible = true;
    });
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isBigHeartVisible = false;
        });
      }
    });
  }

  // ⭐️ 프로필 이미지를 누르면 해당 유저의 프로필로 이동
  void _navigateToProfile() {
    final user = MOCK_USERS[widget.post.username];
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(user: user),
        ),
      );
    }
  }

  // ⭐️ 이미지 빌더
  Widget _buildPostImage() {
    final image = widget.post.image;
    if (image is File) {
      return Image.file(image,
          height: 350, width: double.infinity, fit: BoxFit.cover);
    } else if (image is String) {
      if (image.startsWith('http')) {
        return Image.network(image,
            height: 350, width: double.infinity, fit: BoxFit.cover);
      }
      return Image.asset(image,
          height: 350, width: double.infinity, fit: BoxFit.cover);
    }
    return Container(height: 350, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (프사 + 이름) -> 클릭 시 프로필 이동
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GestureDetector(
              onTap: _navigateToProfile, // ⭐️ 추가됨
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        widget.post.userProfilePicAsset.startsWith('assets/')
                            ? AssetImage(widget.post.userProfilePicAsset)
                                as ImageProvider
                            : null,
                    child:
                        !widget.post.userProfilePicAsset.startsWith('assets/')
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),
            ),
          ),

          // 2. 이미지 (더블탭 좋아요)
          GestureDetector(
            onDoubleTap: _handleDoubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildPostImage(),
                AnimatedOpacity(
                  opacity: _isBigHeartVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(CupertinoIcons.heart_fill,
                      color: Colors.white, size: 100),
                ),
              ],
            ),
          ),

          // 3. 액션 버튼
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLiked
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: widget.post.isLiked ? Colors.red : primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    widget.post.isLiked = !widget.post.isLiked;
                    if (widget.post.isLiked) {
                      widget.post.likes++;
                    } else {
                      widget.post.likes--;
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.chat_bubble),
                onPressed: () {
                  // ⭐️ 댓글 화면은 나중에 모델 구조로 바꾸거나 현재 유지
                  // (여기선 간단히 넘어가기 위해 빈 리스트로 임시 처리하거나 기존 방식 유지)
                },
              ),
              IconButton(
                  icon: const Icon(CupertinoIcons.paperplane),
                  onPressed: () {}),
              const Spacer(),
              IconButton(
                  icon: const Icon(CupertinoIcons.bookmark), onPressed: () {}),
            ],
          ),

          // 4. 정보 (좋아요 수, 캡션)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.post.likes} likes',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: primaryColor),
                    children: [
                      TextSpan(
                        text: '${widget.post.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.post.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
