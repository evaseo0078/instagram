import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart'; // ⚠️ 경로 확인

class CommentsScreen extends StatefulWidget {
  // 1. 부모(PostWidget)로부터 댓글 리스트를 전달받을 "그릇"
  final List<Map<String, dynamic>> commentsList;

  // 2. 생성자를 수정하여 'commentsList'를 필수로 받도록 함
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
        // 3. 부모가 전달해준 'widget.commentsList'에 직접 추가
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
      // ⭐️ 키보드가 올라올 때 화면이 밀리는 것을 방지
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Comments'),
        centerTitle: false,
      ),

      body: Column(
        children: [
          // ⭐️ 1. 댓글 목록 (스크롤 영역)
          Expanded(
            child: ListView.builder(
              itemCount: widget.commentsList.length,
              itemBuilder: (context, index) {
                final commentData = widget.commentsList[index];

                return ListTile(
                  leading: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                  ),
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
                        commentData["isLiked"] = !commentData["isLiked"];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // ⭐️⭐️ 2. 댓글 입력창 (사라졌던 부분!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
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
