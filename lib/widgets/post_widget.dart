import 'dart:async';
import 'dart:io'; // ⭐️ 1. File 이미지를 표시하기 위해 import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/utils/colors.dart';

class PostWidget extends StatefulWidget {
  // ⭐️ 2. 부모로부터 게시물 데이터를 받을 "그릇"
  final Map<String, dynamic> postData;

  const PostWidget({
    super.key,
    required this.postData, // ⭐️ 3. 필수로 받도록 수정
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _isBigHeartVisible = false;

  // ⭐️ 4. 댓글 리스트를 postData로부터 가져옴
  // (이제 이 위젯이 댓글을 "소유"하지 않음)
  late List<Map<String, dynamic>> _comments;

  @override
  void initState() {
    super.initState();
    // ⭐️ 5. 부모가 준 데이터로 댓글 리스트 초기화
    _comments = widget.postData['commentsList'];
  }

  void _handleDoubleTapLike() {
    setState(() {
      _isLiked = true;
      _isBigHeartVisible = true;
    });
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isBigHeartVisible = false;
      });
    });
  }

  // ⭐️ 6. 이미지 위젯을 동적으로 반환하는 함수
  // (새로 올린 'File' 이미지와 기존 'Asset' 이미지를 구분하기 위함)
  Widget _buildPostImage() {
    // 'imagePath'는 File 객체일 수도, String(asset 경로)일 수도 있음
    final imagePath = widget.postData['imagePath'];

    if (imagePath is File) {
      // 새로 추가된 'File' 이미지인 경우
      return Image.file(
        imagePath,
        height: 350,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (imagePath is String) {
      // 기존 'Asset' 이미지인 경우 (나중에 DB에서 가져올 땐 'NetworkImage' 사용)
      return Image.asset(
        imagePath, // 예: 'assets/images/my_image.png'
        height: 350,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      // 임시 회색 박스 (기본값)
      return Container(
        height: 350,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 100, color: Colors.grey),
        ),
      );
    }
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
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  // ⭐️ 7. 'userImage' 사용 (지금은 없으니 임시)
                  // backgroundImage: NetworkImage(widget.postData['userImage']),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.postData['username'], // ⭐️ 8. 'username' 사용
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),

          // 2. 게시물 이미지
          GestureDetector(
            onDoubleTap: _handleDoubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ⭐️ 9. _buildPostImage() 함수로 이미지 표시
                _buildPostImage(),
                AnimatedOpacity(
                  opacity: _isBigHeartVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ],
            ),
          ),

          // 3. 아이콘 버튼
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
                icon: const Icon(CupertinoIcons.chat_bubble),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        // ⭐️ 10. _comments 리스트 전달
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

          // 4. 좋아요 수, 캡션, 댓글 수
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLiked)
                  const Text('1 like',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: primaryColor),
                    children: [
                      TextSpan(
                        text: '${widget.postData['username']} ', // ⭐️
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.postData['caption']), // ⭐️
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View all ${_comments.length} comments', // ⭐️
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
