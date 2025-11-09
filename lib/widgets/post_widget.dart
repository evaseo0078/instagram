import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/comments_screen.dart'; // ⭐️ 1. comments_screen import
import 'package:instagram/utils/colors.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;

  // ⭐️ 2. 댓글 리스트를 CommentsScreen에서 여기로 "이사"시킵니다.
  final List<Map<String, dynamic>> _comments = [
    {
      "username": "ta_junhyuk",
      "comment": "I love puang",
      "time": "1s ago",
      "isLiked": false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ( ... 1. 게시물 헤더 ... )
          // ( ... 2. 게시물 이미지 ... )

          // 3. 아이콘 버튼 (좋아요, 댓글, 공유, 저장)
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: _isLiked ? Colors.red : primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
              ),
              IconButton(
                // '댓글' 버튼
                icon: const Icon(CupertinoIcons.chat_bubble),

                // ⭐️ 3. CommentsScreen으로 이동할 때, 우리가 보관 중인
                // ⭐️ '_comments' 리스트를 "전달"합니다.
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        // ⭐️ 4. 생성자에 리스트 전달
                        commentsList: _comments,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.paperplane),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(CupertinoIcons.bookmark),
                onPressed: () {},
              ),
            ],
          ),

          // ( ... 4. 좋아요 수, 캡션 ... )

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLiked)
                  const Text(
                    '1 like',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: primaryColor),
                    children: [
                      TextSpan(
                        text: 'ta_junhyuk ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'I love puang'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // ⭐️ 5. 댓글 수도 'View all' 대신 실제 리스트의 길이를 표시
                Text(
                  'View all ${_comments.length} comments',
                  style: const TextStyle(color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
