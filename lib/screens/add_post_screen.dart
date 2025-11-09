import 'dart:io'; // ⭐️ 1. 파일(File)을 다루기 위해 필요
import 'package:flutter/material.dart';

// 갤러리에서 선택한 이미지를 받아오는 "캡션 작성 화면"
class AddPostScreen extends StatefulWidget {
  final File imageFile; // ⭐️ 2. 선택된 이미지 파일을 전달받음

  const AddPostScreen({super.key, required this.imageFile});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // ⭐️ 3. 뒤로가기 버튼
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New post'),
        centerTitle: false,
        actions: [
          // ⭐️ 4. "Share" (공유) 버튼
          TextButton(
            onPressed: () {
              // ⭐️ 5. "Share" 누르면 캡션 내용을 가지고 "돌아감"
              Navigator.of(context).pop(_captionController.text);
            },
            child: const Text(
              'Share',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐️ 6. 선택된 이미지 미리보기
                Image.file(
                  widget.imageFile,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                // ⭐️ 7. 캡션 입력창
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...', // 영상 2:01
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
