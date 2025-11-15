// 📍 lib/screens/edit_name_screen.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

class EditNameScreen extends StatefulWidget {
  final String currentName;
  const EditNameScreen({super.key, required this.currentName});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // (영상 04:06 / image_ec25ab.png) 확인 팝업
  void _showConfirmationDialog() {
    // 팝업이 이미 떠있으면 중복 실행 방지
    if (Navigator.of(context).canPop() == false) return;

    final newName = _nameController.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor, // ⭐️ 라이트 모드 배경
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to change your name to $newName?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              const SizedBox(height: 12),
              const Text(
                'You can only change your name twice within 14 days.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: secondaryColor),
              ),
              const Divider(height: 24),
              TextButton(
                onPressed: () {
                  // "Change name"
                  Navigator.of(context).pop(); // 팝업 닫기
                  Navigator.of(context).pop(newName); // 화면 닫고 이름 반환
                },
                child: const Text('Change name',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              TextButton(
                onPressed: () {
                  // "Cancel"
                  Navigator.of(context).pop(); // 팝업 닫기
                },
                child:
                    const Text('Cancel', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          insetPadding: const EdgeInsets.all(32),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryColor), // "X" 버튼
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue), // "V" 버튼
            onPressed: _showConfirmationDialog, // 팝업 띄우기
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name',
                style: TextStyle(color: secondaryColor, fontSize: 12)),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // (image_ec1f22.png) 헬퍼 텍스트
            const Text(
              'Help people discover your account by using the name you\'re known by: either your full name, nickname, or business name.',
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can only change your name twice within 14 days.',
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
