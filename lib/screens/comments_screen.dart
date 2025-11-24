// 📍 lib/screens/comments_screen.dart 전체 수정

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommentsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> commentsList;

  const CommentsScreen({super.key, required this.commentsList});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isComposing = false; // 글자 입력 중인지 여부

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isComposing = _commentController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_isComposing) {
      setState(() {
        widget.commentsList.add({
          "username": "ph.brown", // 내 아이디
          "comment": _commentController.text,
          "time": "Just now",
          "isLiked": false,
        });
        _commentController.clear();
        _isComposing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ Scaffold 대신 Container 등 사용 (바텀시트 내부이므로)
    // 키보드가 올라오면 패딩을 줘서 입력창을 밀어올립니다.
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          // 바텀시트 핸들 (회색 작은 바)
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
          const Divider(),

          // 댓글 리스트 or "No comments yet"
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage(
                                  'assets/images/profiles/my_profile.png'), // 임시 내 프사
                              // 실제 데이터에 유저 프사가 있다면 그걸 쓰세요
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: primaryColor, fontSize: 14),
                                      children: [
                                        TextSpan(
                                            text: '${commentData["username"]} ',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: commentData["comment"]),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(commentData["time"] ?? "Just now",
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12)),
                                      const SizedBox(width: 16),
                                      const Text('Reply',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              commentData["isLiked"]
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              size: 14,
                              color: commentData["isLiked"]
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ⭐️ 댓글 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: secondaryColor),
                    ),
                  ),
                ),
                _isComposing
                    ? GestureDetector(
                        onTap: _postComment,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_upward,
                              color: Colors.white, size: 22),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: SvgPicture.asset(
                            'assets/icons/smile_square.svg',
                            color: Colors.grey,
                          ),
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
