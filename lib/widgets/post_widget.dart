// 📍 lib/widgets/post_widget.dart 전체 수정

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/utils/colors.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isBigHeartVisible = false;
  int _currentImageIndex = 0;

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

  // ⭐️ 댓글 창을 "바텀 시트"로 띄우는 함수
  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 높이 제어 가능하게 함
      backgroundColor: Colors.transparent, // 뒷배경 투명
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9, // 화면의 90% 높이
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        // ⭐️ 댓글 리스트를 그대로 넘겨줍니다.
        child: CommentsScreen(commentsList: widget.post.comments),
      ),
    ).then((_) {
      // 창이 닫히면 화면 갱신 (댓글 개수 등 반영)
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // 댓글 미리보기용 데이터 (첫 번째 댓글)
    final Map<String, dynamic>? firstComment =
        widget.post.comments.isNotEmpty ? widget.post.comments.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더
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
              const Icon(Icons.more_vert),
            ],
          ),
        ),

        // 2. 이미지 (4:3 비율, 꽉 차게)
        // 2. 이미지 (⭐️ 원본 비율 유지)
        GestureDetector(
          onDoubleTap: _handleDoubleTapLike,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ⭐️ AspectRatio 제거! 대신 Container로 감싸지 않고 바로 PageView를 쓰려면 높이가 필요함.
              // 하지만 원본 비율을 유지하려면 PageView 대신 그냥 Image를 써야 함.
              // (여러 장일 땐 PageView가 필수라 높이가 필요하지만, 인스타그램은 보통 1:1이나 4:5로 자름)
              // 여기서는 "가로폭에 맞춰 높이 자동 조절"을 위해 아래처럼 처리합니다.

              widget.post.images.length > 1
                  ? SizedBox(
                      // 여러 장일 땐 어쩔 수 없이 높이를 지정해야 함 (인스타도 1:1 권장)
                      height: 400, // 혹은 MediaQuery.of(context).size.width (1:1)
                      child: PageView.builder(
                        itemCount: widget.post.images.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          final imagePath = widget.post.images[index];
                          if (imagePath.startsWith('assets/')) {
                            return Image.asset(imagePath,
                                fit: BoxFit.contain); // ⭐️ 잘리지 않게 contain
                          } else {
                            return Image.file(File(imagePath),
                                fit: BoxFit.contain);
                          }
                        },
                      ),
                    )
                  : // 한 장일 땐 높이 제한 없이 원본 비율 그대로 출력!
                  (widget.post.images[0].startsWith('assets/')
                      ? Image.asset(widget.post.images[0], fit: BoxFit.cover)
                      : Image.file(File(widget.post.images[0]),
                          fit: BoxFit.cover)),

              AnimatedOpacity(
                opacity: _isBigHeartVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(CupertinoIcons.heart_fill,
                    color: Colors.white, size: 100),
              ),
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

        // 3. 아이콘 버튼들
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    widget.post.isLiked = !widget.post.isLiked;
                    widget.post.isLiked
                        ? widget.post.likes++
                        : widget.post.likes--;
                  });
                },
                child: Icon(
                  widget.post.isLiked
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: widget.post.isLiked ? Colors.red : primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // ⭐️ 댓글 아이콘 -> 바텀시트 연결
              InkWell(
                onTap: _showCommentsModal,
                child: const Icon(CupertinoIcons.chat_bubble, size: 28),
              ),
              const SizedBox(width: 16),

              // ⭐️ 리포스트 아이콘 (더 얇은 것으로 교체)
              InkWell(
                onTap: () {},
                // 네모난 리포스트 느낌의 아이콘 사용
                child: const Icon(Icons.repeat, size: 28),
              ),
              const SizedBox(width: 16),

              InkWell(
                onTap: () {},
                child: const Icon(CupertinoIcons.paperplane, size: 28),
              ),

              const Spacer(),

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
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              const Spacer(),

              const Icon(CupertinoIcons.bookmark, size: 28),
            ],
          ),
        ),

        // 4. 정보 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.post.likes} likes',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: primaryColor, fontSize: 14),
                  children: [
                    TextSpan(
                        text: '${widget.post.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // ⭐️ 실제 데이터 반영된 댓글 미리보기
              if (firstComment != null) ...[
                Row(
                  children: [
                    Text('${firstComment['username']} ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Expanded(
                      child: Text(
                        firstComment['comment'],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Icon(CupertinoIcons.heart,
                        size: 14, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _showCommentsModal, // 여기 눌러도 댓글창 열림
                  child: const Text('View all comments',
                      style: TextStyle(color: secondaryColor, fontSize: 14)),
                ),
              ],

              const SizedBox(height: 4),
              const Text('September 19',
                  style: TextStyle(color: secondaryColor, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
