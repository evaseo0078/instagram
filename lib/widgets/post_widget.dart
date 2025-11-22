import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/screens/comments_screen.dart'; // 댓글 화면
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/utils/colors.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isBigHeartVisible = false;
  int _currentImageIndex = 0; // ⭐️ 현재 사진 번호 (0, 1, 2...)

  // 좋아요 더블 탭
  void _handleDoubleTapLike() {
    setState(() {
      widget.post.isLiked = true;
      widget.post.likes++;
      _isBigHeartVisible = true;
    });
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isBigHeartVisible = false);
    });
  }

  // 프로필 이동
  void _navigateToProfile() {
    final user = MOCK_USERS[widget.post.username];
    if (user != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
    }
  }

  // ⭐️ 댓글 화면으로 이동하는 함수 (영상 2:31)
  void _navigateToComments() async {
    // CommentsScreen으로 이동하면서 현재 게시물의 댓글 리스트를 통째로 넘김
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          commentsList:
              widget.post.comments, // ⭐️ List<Map<String, dynamic>> 전달
        ),
      ),
    );

    // 댓글 화면에서 돌아오면 화면을 갱신하여 댓글 수 등을 반영
    if (mounted) {
      setState(() {});
    }
  }

  // ⭐️ 이미지 1개를 그리는 함수
  Widget _buildSingleImage(dynamic imagePath) {
    if (imagePath is File) {
      return Image.file(imagePath, fit: BoxFit.cover, width: double.infinity);
    } else if (imagePath is String) {
      if (imagePath.startsWith('http')) {
        return Image.network(imagePath,
            fit: BoxFit.cover, width: double.infinity);
      }
      return Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity);
    }
    return Container(color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더 (프사 + 이름)
        Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: _navigateToProfile,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  // ⭐️ 프로필 이미지 로직 적용
                  backgroundImage:
                      _getProfileImageProvider(widget.post.userProfilePicAsset),
                ),
                const SizedBox(width: 8),
                Text(widget.post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.more_vert),
              ],
            ),
          ),
        ),

        // 2. 이미지 (PageView로 여러 장 지원) ⭐️ 중요!
        GestureDetector(
          onDoubleTap: _handleDoubleTapLike,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 400, // 사진 높이
                child: PageView.builder(
                  itemCount: widget.post.images.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildSingleImage(widget.post.images[index]);
                  },
                ),
              ),
              // 좋아요 하트 애니메이션
              AnimatedOpacity(
                opacity: _isBigHeartVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(CupertinoIcons.heart_fill,
                    color: Colors.white, size: 100),
              ),
              // ⭐️ 사진 순서 표시 (점) - 사진이 2장 이상일 때만 표시
              if (widget.post.images.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${_currentImageIndex + 1}/${widget.post.images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 3. 액션 버튼 (좋아요, 댓글 등)
        Row(
          children: [
            IconButton(
              icon: Icon(
                  widget.post.isLiked
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: widget.post.isLiked ? Colors.red : primaryColor),
              onPressed: () {
                setState(() {
                  widget.post.isLiked = !widget.post.isLiked;
                  widget.post.isLiked
                      ? widget.post.likes++
                      : widget.post.likes--;
                });
              },
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.chat_bubble),
              onPressed: _navigateToComments, // ⭐️ 댓글 화면 연결
            ),
            IconButton(
                icon: const Icon(CupertinoIcons.paperplane), onPressed: () {}),

            // ⭐️ Dot Indicator 적용
            _DotIndicator(
              pageCount: widget.post.images.length,
              currentPage: _currentImageIndex,
            ),

            IconButton(
                icon: const Icon(CupertinoIcons.bookmark), onPressed: () {}),
          ],
        ),

        // 4. 캡션 및 좋아요 수
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
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ⭐️ 새로운 중앙 점 인디케이터 위젯 (PostWidget 외부에 정의)
class _DotIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _DotIndicator({required this.pageCount, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    // 사진이 1장이면 인디케이터를 표시하지 않습니다.
    if (pageCount <= 1) return const Spacer();

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPage == index ? Colors.blue : Colors.grey.shade400,
            ),
          );
        }),
      ),
    );
  }
}
