// 📍 lib/widgets/post_widget.dart (전체 덮어쓰기)

import 'dart:async';
import 'dart:io';
import 'dart:math';
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

  void _showCommentsModal() {
    double sheetHeightFactor = 0.7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * sheetHeightFactor,
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            // ?? ??? ???(postOwnerName) ??? ??? ??(Author ???)
            child: CommentsScreen(
              commentsList: widget.post.comments,
              postOwnerName: widget.post.username,
              onExpandHeight: () {
                if (sheetHeightFactor < 0.9) {
                  setModalState(() => sheetHeightFactor = 0.9);
                }
              },
            ),
          );
        });
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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

        // 2. 이미지 (⭐️ 로직 변경)
        AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onDoubleTap: _handleDoubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: widget.post.images.length == 1
                      ? (widget.post.images[0].startsWith('assets/')
                          ? Image.asset(widget.post.images[0],
                              fit: BoxFit.cover, alignment: Alignment.center)
                          : Image.file(File(widget.post.images[0]),
                              fit: BoxFit.cover, alignment: Alignment.center))
                      : PageView.builder(
                          itemCount: widget.post.images.length,
                          onPageChanged: (index) =>
                              setState(() => _currentImageIndex = index),
                          itemBuilder: (context, index) {
                            final imagePath = widget.post.images[index];
                            if (imagePath.startsWith('assets/')) {
                              return Image.asset(imagePath,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center);
                            } else {
                              return Image.file(File(imagePath),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center);
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

                // 사진 번호
                if (widget.post.images.length > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${_currentImageIndex + 1}/${widget.post.images.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 3. 아이콘 버튼들
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
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
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _showCommentsModal,
                      child: const Icon(CupertinoIcons.chat_bubble, size: 28),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {},
                      child:
                          const Icon(CupertinoIcons.arrow_2_squarepath, size: 28),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {},
                      child: const Icon(CupertinoIcons.paperplane, size: 28),
                    ),
                    const Spacer(),
                    const Icon(CupertinoIcons.bookmark, size: 28),
                  ],
                ),
                if (widget.post.images.length > 1)
                  Center(
                    child: Builder(builder: (context) {
                      final total = widget.post.images.length;
                      final visibleCount = min(total, 6);
                      int start = 0;
                      if (total > visibleCount &&
                          _currentImageIndex >= visibleCount - 1) {
                        start = min(_currentImageIndex - (visibleCount - 1),
                            total - visibleCount);
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(visibleCount, (i) {
                          final actualIndex = start + i;
                          final isActive = actualIndex == _currentImageIndex;
                          final size = isActive ? 10.0 : 6.0;
                          return Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 2),
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isActive ? Colors.blue : Colors.grey.shade300,
                            ),
                          );
                        }),
                      );
                    }),
                  ),
              ],
            ),
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
              if (firstComment != null) ...[
                Row(
                  children: [
                    Text('${firstComment['username']} ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Expanded(
                      child: Text(firstComment['comment'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14)),
                    ),
                    Icon(CupertinoIcons.heart,
                        size: 14, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _showCommentsModal,
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
