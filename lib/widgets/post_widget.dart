// 📍 lib/widgets/post_widget.dart (전체 수정)

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/utils/colors.dart';
// import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 필요할 수 있음 (일단 하드코딩으로 처리)

class PostWidget extends StatefulWidget {
  final PostModel post;
  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isBigHeartVisible = false;
  int _currentImageIndex = 0;

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

  // 댓글 화면 이동
  void _navigateToComments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          commentsList: widget.post.comments,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더 (프로필 사진 + 이름 + 더보기)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    widget.post.userProfilePicAsset.startsWith('assets/')
                        ? AssetImage(widget.post.userProfilePicAsset)
                            as ImageProvider
                        : FileImage(File(widget.post.userProfilePicAsset)),
              ),
              const SizedBox(width: 10),
              Text(
                widget.post.username,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              const Icon(Icons.more_vert), // 더보기 아이콘
            ],
          ),
        ),

        // 2. 이미지 (더블탭 좋아요 기능)
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
                    final imagePath = widget.post.images[index];
                    if (imagePath.startsWith('assets/')) {
                      return Image.asset(imagePath, fit: BoxFit.cover);
                    } else {
                      return Image.file(File(imagePath), fit: BoxFit.cover);
                    }
                  },
                ),
              ),
              // 하트 애니메이션
              AnimatedOpacity(
                opacity: _isBigHeartVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(CupertinoIcons.heart_fill,
                    color: Colors.white, size: 100),
              ),
              // 사진 번호 표시 (1/3)
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

        // 3. 아이콘 버튼들 (하트, 댓글, DM, ..., 북마크)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // 하트 (좋아요)
              IconButton(
                icon: Icon(
                  widget.post.isLiked
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: widget.post.isLiked ? Colors.red : primaryColor,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    widget.post.isLiked = !widget.post.isLiked;
                    widget.post.isLiked
                        ? widget.post.likes++
                        : widget.post.likes--;
                  });
                },
              ),
              // 댓글
              IconButton(
                icon: const Icon(CupertinoIcons.chat_bubble, size: 26),
                onPressed: _navigateToComments,
              ),
              // DM (종이비행기) - 보내주신 사진 참고하여 추가
              IconButton(
                icon: const Icon(CupertinoIcons.paperplane, size: 26),
                onPressed: () {},
              ),

              const Spacer(), // 사이 간격 벌리기

              // 인디케이터 (사진이 여러장일 때만)
              if (widget.post.images.length > 1)
                Row(
                  children: List.generate(widget.post.images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? blueColor
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),

              const Spacer(), // 인디케이터가 중앙에 오도록 처리 (약식)

              // 북마크
              IconButton(
                icon: const Icon(CupertinoIcons.bookmark, size: 26),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // 4. 정보 표시 (좋아요, 캡션, 댓글 미리보기, 날짜)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 좋아요 개수
              Text(
                '${widget.post.likes} likes', // 예: 918,471 likes
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),

              // 캡션 (아이디 + 내용)
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: primaryColor, fontSize: 14),
                  children: [
                    TextSpan(
                      text: '${widget.post.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // ⭐️ 댓글 미리보기 (요청사항: un.k1o ... 하트)
              // 임시로 가짜 댓글 하나를 보여줍니다.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: primaryColor, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'un.k1o ', // 댓글 작성자
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '얼굴을 저렇게 가까이 들이대는데...'), // 댓글 내용
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(CupertinoIcons.heart,
                      size: 12, color: secondaryColor), // 작은 하트
                ],
              ),
              const SizedBox(height: 4),

              // 댓글 모두 보기
              GestureDetector(
                onTap: _navigateToComments,
                child: const Text(
                  'View all comments',
                  style: TextStyle(color: secondaryColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),

              // 날짜 (요청사항: September 19)
              const Text(
                'September 19',
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
