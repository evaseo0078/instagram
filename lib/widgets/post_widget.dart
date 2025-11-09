import 'dart:async'; // ⭐️ 1. 타이머를 위한 import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/utils/colors.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _isBigHeartVisible = false; // ⭐️ 2. 큰 하트 애니메이션용 상태 변수

  // 댓글 리스트 (소유)
  final List<Map<String, dynamic>> _comments = [
    {
      "username": "ta_junhyuk",
      "comment": "I love puang",
      "time": "1s ago",
      "isLiked": false,
    }
  ];

  // ⭐️ 3. 더블 탭 했을 때 호출될 함수
  void _handleDoubleTapLike() {
    // 이미 '좋아요' 상태여도 애니메이션은 보여줄 수 있지만,
    // 인스타그램은 보통 '좋아요'가 아닐 때만 애니메이션을 보여줍니다.
    // 여기서는 '좋아요' 상태로 만들고 애니메이션을 실행합니다.
    setState(() {
      _isLiked = true; // '좋아요' 상태로 변경
      _isBigHeartVisible = true; // 큰 하트 보이기
    });

    // ⭐️ 4. 0.5초(500ms) 후에 큰 하트를 다시 숨김
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isBigHeartVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 게시물 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              // ( ... 헤더 코드는 동일 ... )
              children: [
                const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                const SizedBox(width: 10),
                const Text('ta_junhyuk',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),

          // ⭐️⭐️ 2. 게시물 이미지 (Stack + GestureDetector로 변경) ⭐️⭐️
          GestureDetector(
            onDoubleTap: _handleDoubleTapLike, // ⭐️ 5. 두 번 탭 감지!
            child: Stack(
              alignment: Alignment.center, // ⭐️ 6. 큰 하트를 중앙에 띄우기 위함
              children: [
                // 2-1. 원본 이미지 (회색 박스)
                Container(
                  height: 350,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                ),

                // 2-2. 큰 하트 (애니메이션)
                AnimatedOpacity(
                  // ⭐️ 7. _isBigHeartVisible 값에 따라 투명도 조절
                  opacity: _isBigHeartVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200), // 0.2초간 fade
                  child: const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.white,
                    size: 100, // 큰 하트 아이콘
                  ),
                ),
              ],
            ),
          ),

          // 3. 아이콘 버튼 (좋아요, 댓글, 공유, 저장)
          Row(
            children: [
              IconButton(
                // ⭐️ 8. 하트 버튼은 그냥 _isLiked 상태만 토글
                icon: Icon(
                  _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: _isLiked ? Colors.red : primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked; // 큰 하트 애니메이션 없이 상태만 변경
                  });
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.chat_bubble),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        commentsList: _comments,
                      ),
                    ),
                  );
                },
              ),
              // ( ... 나머지 아이콘 버튼 ... )
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

          // 4. 좋아요 수, 캡션, 댓글 수
          Padding(
            // ( ... 나머지 코드는 동일 ... )
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLiked)
                  const Text('1 like',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
