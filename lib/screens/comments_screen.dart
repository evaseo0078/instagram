// 📍 lib/screens/comments_screen.dart (태블릿 최적화 + 말풍선 위치 수정 + 입력창 디자인)

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommentsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> commentsList;
  final String postOwnerName;
  final VoidCallback? onExpandHeight;

  const CommentsScreen({
    super.key,
    required this.commentsList,
    this.postOwnerName = '',
    this.onExpandHeight,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  Timer? _relativeTimeTicker;

  // 툴팁 상태
  bool _showLikeTooltip = false;
  bool _showPublicContentTooltip = true; // 처음에 안내 문구 띄우기

  int? _replyingToIndex;

  // 퀵 이모지 리스트
  final List<String> _quickEmojis = [
    '❤️',
    '🙌',
    '🔥',
    '👏',
    '😢',
    '😍',
    '😮',
    '😂'
  ];

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isComposing = _commentController.text.isNotEmpty;
      });
    });

    // 5초 뒤에 "Public content" 툴팁 사라지게 하기 (원하면 제거 가능)
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showPublicContentTooltip = false);
    });

    _relativeTimeTicker =
        Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _relativeTimeTicker?.cancel();
    super.dispose();
  }

  void _postComment() {
    if (_isComposing) {
      setState(() {
        // "Public content" 툴팁이 떠있다면 입력 시 제거
        _showPublicContentTooltip = false;

        final newComment = {
          "username": "ph.brown",
          "comment": _commentController.text,
          "createdAt": DateTime.now(),
          "isLiked": false,
          "isPosting": true,
          "isReply": _replyingToIndex != null,
        };

        if (_replyingToIndex != null) {
          widget.commentsList.insert(_replyingToIndex! + 1, newComment);
          _replyingToIndex = null;
        } else {
          widget.commentsList.add(newComment);
        }

        _commentController.clear();
        _isComposing = false;
        _focusNode.unfocus();
      });

      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            for (var comment in widget.commentsList) {
              if (comment["isPosting"] == true) {
                comment["isPosting"] = false;
                comment["createdAt"] = DateTime.now();
                comment["time"] = "Just now";
              }
            }
          });
        }
      });
    }
  }

  void _replyToUser(int index, String username) {
    setState(() {
      _replyingToIndex = index;
      _commentController.text = "@$username ";
      _commentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _commentController.text.length));
    });
    _focusNode.requestFocus();
    widget.onExpandHeight?.call();
  }

  void _toggleLike(int index) {
    setState(() {
      widget.commentsList[index]["isLiked"] =
          !widget.commentsList[index]["isLiked"];
      if (widget.commentsList[index]["isLiked"]) {
        _showLikeTooltip = true;
        // 3초 뒤 사라짐
        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showLikeTooltip = false);
        });
      }
    });
  }

  void _addEmoji(String emoji) {
    setState(() {
      _commentController.text = _commentController.text + emoji;
      _commentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _commentController.text.length));
      _isComposing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              // 바텀시트 핸들
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Comments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(height: 1),

              // 댓글 리스트
              Expanded(
                child: widget.commentsList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('No comments yet',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Start the conversation.',
                                style: TextStyle(color: secondaryColor)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.commentsList.length,
                        itemBuilder: (context, index) {
                          final commentData = widget.commentsList[index];
                          final bool isAuthor =
                              commentData['username'] == widget.postOwnerName ||
                                  commentData['username'] == 'ph.brown';
                          final bool isPosting =
                              commentData['isPosting'] ?? false;
                          final bool isReply = commentData['isReply'] ?? false;
                          final DateTime? createdAt =
                              commentData['createdAt'] as DateTime?;
                          String timeText = '12s';
                          if (isPosting) {
                            timeText = 'Posting...';
                          } else if (createdAt != null) {
                            final diff =
                                DateTime.now().difference(createdAt);
                            if (diff.inMinutes < 1) {
                              timeText = 'Just now';
                            } else if (diff.inHours < 1) {
                              timeText = '${diff.inMinutes}m';
                            } else if (diff.inDays < 1) {
                              timeText = '${diff.inHours}h';
                            } else {
                              timeText = '${diff.inDays}d';
                            }
                          } else if (commentData["time"] != null) {
                            timeText = '${commentData["time"]}';
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              right: 16,
                              left: isReply ? 50 : 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: commentData['username'] ==
                                          'ph.brown'
                                      ? const AssetImage(
                                          'assets/images/profiles/my_profile.png')
                                      : const AssetImage(
                                          'assets/images/profiles/kid_go.png'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: primaryColor,
                                              fontSize: 14),
                                      children: [
                                        TextSpan(
                                            text:
                                                '${commentData["username"]} ',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold)),
                                        TextSpan(
                                            text: '$timeText ',
                                                style: const TextStyle(
                                                    color: secondaryColor)),
                                        TextSpan(
                                                text: commentData["comment"]),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (isPosting)
                                            const Text('Posting...',
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 12))
                                          else
                                            GestureDetector(
                                              onTap: () => _replyToUser(index,
                                                  commentData["username"]),
                                              child: const Text('Reply',
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          if (isAuthor) ...[
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Author',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: secondaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _toggleLike(index),
                                  child: Column(
                                    children: [
                                      Icon(
                                        commentData["isLiked"]
                                            ? CupertinoIcons.heart_fill
                                            : CupertinoIcons.heart,
                                        size: 14,
                                        color: commentData["isLiked"]
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      if (commentData["isLiked"])
                                        const Text("1",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: secondaryColor))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // ⭐️ 퀵 이모지 바 (태블릿 800px 대응: spaceAround 사용)
              Container(
                height: 50,
                color: backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  // ⭐️ 800px 너비에 맞춰 이모티콘을 균등하게 배분
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _quickEmojis.map((emoji) {
                    return GestureDetector(
                      onTap: () => _addEmoji(emoji),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    );
                  }).toList(),
                ),
              ),

              // ⭐️ 댓글 입력창 (Rounded Rectangle + 내부 아이콘)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  color: backgroundColor,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          AssetImage('assets/images/profiles/my_profile.png'),
                    ),
                    const SizedBox(width: 12),
                    // ⭐️ 입력창 부분
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // 회색 배경
                          borderRadius: BorderRadius.circular(24), // 완전 둥근 모양
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: InputBorder.none, // 테두리 제거
                                  hintStyle: TextStyle(color: secondaryColor),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                  isDense: true,
                                ),
                              ),
                            ),
                            // ⭐️ 입력 안 할 때: 이모티콘 아이콘 (입력창 내부)
                            if (!_isComposing)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset(
                                  'assets/icons/smile_square.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.grey, BlendMode.srcIn),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // ⭐️ 입력 중일 때만: 외부에 파란 전송 버튼 표시
                    if (_isComposing) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _postComment,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_upward,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),

        // ⭐️ 1. "Public Content" 안내 말풍선 (하단 입력창 위)
        if (_showPublicContentTooltip)
          Positioned(
            bottom: 110, // 입력창 높이 고려해서 띄움
            left: 20, right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Text(
                    'Comments on public content can now be shared by others in their stories and reels.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                // 말풍선 꼬리 (아래쪽)
                CustomPaint(
                  painter: TrianglePainter(isDown: true),
                  size: const Size(12, 8),
                ),
              ],
            ),
          ),

        // ⭐️ 2. "Double tap" 툴팁 (상단 하트 근처)
        if (_showLikeTooltip)
          Positioned(
            top: 50, // 첫 번째 댓글 위치쯤
            right: 40, // 하트 아이콘 위치 고려
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Text(
                    'Now you can double tap a comment to like it.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                // 말풍선 꼬리 (아래쪽, 우측 치우침)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomPaint(
                    painter: TrianglePainter(isDown: true),
                    size: const Size(10, 8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ⭐️ 말풍선 꼬리 그리기 (위/아래 방향 지원)
class TrianglePainter extends CustomPainter {
  final bool isDown;
  TrianglePainter({this.isDown = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();

    if (isDown) {
      // 역삼각형 (▼)
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    } else {
      // 정삼각형 (▲)
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }

    path.close();
    // 그림자 효과 살짝 추가
    canvas.drawShadow(path, Colors.black26, 2.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
