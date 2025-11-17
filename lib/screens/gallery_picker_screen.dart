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
    // ⭐️ 5. UI를 영상과 유사하게 맞춤
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
            // ⭐️ 6. "Next" (영상 1:52)
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
          Container(
            height: 350,
            color: Colors.grey[900],
            child: _selectedImageFile == null
                ? Center(
                    child: TextButton(
                      onPressed: _pickImageFromGallery,
                      child: const Text('Choose from Gallery'),
                    ),
                  )
                : Image.file(_selectedImageFile!, fit: BoxFit.contain),
          ),
          // ⭐️ 7. 하단 그리드 뷰는 에뮬레이터/웹에서 구현이 복잡하므로
          //     교수님 요구사항(영상 흐름)에 맞춰 메인 프리뷰에 집중합니다.
          Expanded(
            child: Container(
              color: backgroundColor,
              child: const Center(
                child: Text('Image preview'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
