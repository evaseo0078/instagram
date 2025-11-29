// 📍 lib/screens/gallery_picker_screen.dart (image_picker로 교체)

import 'dart:io';
import 'package:flutter/material.dart';
// ⭐️ 1. image_picker import (크롬/에뮬레이터 호환)
import 'package:image_picker/image_picker.dart';
import 'package:instagram/utils/colors.dart';

// (photo_manager 관련 import 모두 삭제)

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ⭐️ 2. 화면이 열리자마자 바로 갤러리를 띄웁니다 (영상 1:46)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImageFromGallery();
    });
  }

  // ⭐️ 3. image_picker를 사용해 갤러리 열기
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    } else {
      // 갤러리에서 선택 안하고 닫으면, 이 화면 자체를 닫음
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ⭐️ 4. "Next" (게시물) / "Done" (프로필) 버튼
  void _onDoneOrNextPressed() {
    if (_selectedImageFile != null) {
      Navigator.of(context).pop(_selectedImageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomNavHeight = 120.0; // 하단 옵션 영역

    // 이미지 미리보기 높이 = 전체 화면 - 앱바 - 하단영역
    final imagePreviewHeight =
        screenHeight - appBarHeight - statusBarHeight - bottomNavHeight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Recents', style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _onDoneOrNextPressed,
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 선택된 이미지 큰 미리보기
          Container(
            height: imagePreviewHeight,
            width: double.infinity,
            color: Colors.white,
            child: _selectedImageFile == null
                ? Center(
                    child: TextButton(
                      onPressed: _pickImageFromGallery,
                      child: const Text('Choose from Gallery',
                          style: TextStyle(fontSize: 16)),
                    ),
                  )
                : Image.file(
                    _selectedImageFile!,
                    fit: BoxFit.contain, // 전체가 보이도록, 잘리지 않게
                  ),
          ),
          // 하단 옵션 영역
          Container(
            height: bottomNavHeight,
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 왼쪽 버튼 (갤러리 재선택)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 20),
                    label: const Text('GALLERY'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 중간 버튼 (사진 촬영)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final XFile? photo = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (photo != null) {
                        setState(() {
                          _selectedImageFile = File(photo.path);
                        });
                      }
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: const Text('PHOTO'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 오른쪽 버튼 (다중 선택)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 다중 선택 기능 (옵션)
                    },
                    icon:
                        const Icon(Icons.library_add_check_outlined, size: 20),
                    label: const Text('SELECT MULTIPLE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
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
