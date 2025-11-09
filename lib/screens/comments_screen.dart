import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

class CommentsScreen extends StatefulWidget {
  // ⭐️ 1. 부모(PostWidget)로부터 댓글 리스트를 전달받을 "그릇" 준비
  final List<Map<String, dynamic>> commentsList;

  // ⭐️ 2. 생성자를 수정하여 'commentsList'를 필수로 받도록 함
  const CommentsScreen({
    super.key,
    required this.commentsList,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _canPost = false;

  // ⭐️ 3. 여기서 리스트를 직접 만들지 않습니다! (PostWidget이 주인이므로)
  // final List<Map<String, dynamic>> _comments = [ ... ]; // <-- ⭐️ 이 줄 삭제

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _canPost = _commentController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_canPost) {
      setState(() {
        // ⭐️ 4. 부모가 전달해준 'widget.commentsList'에 직접 추가합니다.
        // (이렇게 하면 PostWidget이 가진 원본 리스트가 수정됩니다)
        widget.commentsList.add({
          "username": "ta_junhyuk",
          "comment": _commentController.text,
          "time": "Just now",
          "isLiked": false,
        });

        _commentController.clear();
        _canPost = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ( ... AppBar 코드는 동일 ... )
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // ⭐️ 5. 부모가 준 'widget.commentsList'의 길이를 사용
              itemCount: widget.commentsList.length,
              itemBuilder: (context, index) {
                // ⭐️ 6. 부모가 준 'widget.commentsList'의 데이터를 사용
                final commentData = widget.commentsList[index];

                return ListTile(
                  // ( ... ListTile 코드는 동일 ... )
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: '${commentData["username"]} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: commentData["comment"]),
                      ],
                    ),
                  ),
                  subtitle: Text(commentData["time"]!),
                  trailing: IconButton(
                    icon: Icon(
                      commentData["isLiked"]
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      size: 16,
                      color: commentData["isLiked"] ? Colors.red : primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        // ⭐️ 7. 'widget.commentsList'의 데이터를 수정
                        commentData["isLiked"] = !commentData["isLiked"];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // ⭐️ (하단 댓글 입력창 코드는 동일)
          Container(
            // ( ... Container, Row, TextField 코드는 동일 ... )
            child: Row(
              children: [
                // ( ... CircleAvatar, Expanded(TextField) ... )
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  color: _canPost ? Colors.blue : secondaryColor,
                  onPressed: _canPost ? _postComment : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
