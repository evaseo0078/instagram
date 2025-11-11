// 📍 lib/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  // 1. profile_screen.dart로부터 "현재" 닉네임과 바이오를 전달받음
  final String currentName;
  final String currentBio;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 2. TextField를 제어하기 위한 컨트롤러
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // 3. 컨트롤러를 "현재" 닉네임/바이오로 초기화
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // 4. "Done" 버튼을 눌렀을 때 실행될 함수
  void _saveAndReturn() {
    // 5. 변경된 텍스트를 Map 형태로 묶어서 이전 화면으로 "반환"
    Navigator.of(context).pop({
      'name': _nameController.text,
      'bio': _bioController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Cancel" 버튼 (영상 03:54)
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: primaryColor)),
        ),
        title: const Text('Edit profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // "Done" 버튼
        actions: [
          TextButton(
            onPressed: _saveAndReturn, // ⭐️ 저장 함수 연결
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 6. 이름 입력 필드 (영상 03:56)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            // 7. 바이오 입력 필드 (영상 04:15)
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
