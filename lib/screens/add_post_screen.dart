// 📍 lib/screens/add_post_screen.dart (전체 덮어쓰기)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart'; // backgroundColor, primaryColor 사용
import 'package:instagram/data/mock_data.dart'; // 내 정보 가져오기

class AddPostScreen extends StatefulWidget {
  final File imageFile;

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
    // 내 정보 (brown) 가져오기
    final myUser = MOCK_USERS['brown']!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New post',
          style: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 작성 내용 반환
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // ⭐️ 상단: 이미지 썸네일 + 캡션 입력창
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 위쪽 정렬
              children: [
                // 1. 선택된 이미지 썸네일 (영상처럼 작게)
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover, // 꽉 채우기
                  ),
                ),
                const SizedBox(width: 12),

                // 2. 캡션 입력창
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: null, // 줄바꿈 자유롭게
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 0.5),

            // 3. (옵션) 추가 메뉴들 (영상 디테일)
            _buildOptionRow('Tag people'),
            _buildOptionRow('Add location'),
            _buildOptionRow('Add music'),
          ],
        ),
      ),
    );
  }

  // 메뉴 한 줄 만드는 함수
  Widget _buildOptionRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
