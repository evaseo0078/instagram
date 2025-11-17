// 📍 lib/screens/edit_profile_screen.dart (모든 오류 수정 최종본)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_bio_screen.dart';
import 'package:instagram/screens/edit_filter_screen.dart'; // (게시물용으로 여전히 필요)
import 'package:instagram/screens/edit_name_screen.dart';
import 'package:instagram/screens/gallery_picker_screen.dart';
import 'package:instagram/utils/colors.dart';
// ⭐️ 1. 로딩 유틸리티 import (오류 해결!)
import 'package:instagram/utils/loading_utils.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final File? currentProfilePic;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBio,
    this.currentProfilePic,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _newProfilePicFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
    _newProfilePicFile = widget.currentProfilePic;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAvatarDialog(context);
    });
  }

  // (영상 03:34) 아바타 팝업
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ⭐️ 2. (스크린샷 213838.png 기준)
                // ⭐️ 아바타 팝업의 이미지를 Asset으로 복구
                Image.asset(
                  'assets/images/avatar_promo.png', // ⭐️ 이 Asset이 필요합니다!
                  height: 100,
                  // ⭐️ 만약 이 파일도 없다면, 임시 아이콘으로 대체하세요:
                  errorBuilder: (context, error, stackTrace) {
                    print("ERROR: 'assets/images/avatar_promo.png' not found.");
                    return const Icon(Icons.people,
                        size: 100, color: primaryColor);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create your avatar',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get your own personalized\nstickers to share in stories\nand chats.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: secondaryColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Create avatar',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: secondaryColor,
                  indent: 16,
                  endIndent: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Not now',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // "Done" 버튼 (저장 로직)
  Future<void> _saveAndReturn() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    // "Done" 누르면 "Saving..." 팝업 (영상엔 없지만 로딩 처리를 위해 추가)
    showLoadingDialog(context, 'Saving...');
    await Future.delayed(const Duration(milliseconds: 500));

    hideLoadingDialog(context);

    if (mounted) {
      Navigator.of(context).pop({
        'name': _nameController.text,
        'bio': _bioController.text,
        'image': _newProfilePicFile,
      });
    }
  }

  // ⭐️ 3. (영상 03:38) 프로필 사진 변경 흐름 (필터 스킵)
  Future<void> _pickImageFromGallery() async {
    Navigator.of(context).pop(); // 1. 바텀시트 닫기

    // 2. 갤러리 화면 (영상 03:39)
    final File? originalFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GalleryPickerScreen(),
      ),
    );
    if (originalFile == null) return; // 갤러리에서 "X" 누름

    // 3. (요청사항) 필터 화면을 건너뛰고 "Loading..." 팝업 띄우기 (영상 3:44)
    showLoadingDialog(context, 'Loading...');
    await Future.delayed(const Duration(milliseconds: 300)); // (영상처럼 잠시 멈춤)

    // 4. 최종 이미지로 상태 업데이트
    setState(() {
      _newProfilePicFile = originalFile;
    });

    // 5. "Loading..." 팝업 닫기
    hideLoadingDialog(context);
  }

  // (영상 03:37) 프로필 사진 바텀시트
  void _showProfilePicOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _newProfilePicFile != null
                          ? FileImage(_newProfilePicFile!)
                          : null,
                      child: _newProfilePicFile == null
                          ? const Icon(Icons.person,
                              size: 32, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // ⭐️ 4. 아바타 아이콘을 asset 대신 기본 아이콘으로 변경
                    // (이건 영상의 '사람 얼굴' 아이콘 대체입니다)
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[850],
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('Choose from library'),
                  onTap: _pickImageFromGallery, // ⭐️ 수정된 함수 연결
                ),
                ListTile(
                  leading: const Icon(Icons.facebook),
                  title: const Text('Import from Facebook'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take photo'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _newProfilePicFile = null;
                    });
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: secondaryColor, fontSize: 12),
                      children: [
                        TextSpan(
                            text:
                                'Your profile picture and avatar are visible to everyone on and off Instagram.\n'),
                        TextSpan(
                          text: 'Learn more.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // "Name" 탭 -> 새 화면
  Future<void> _navigateToName() async {
    final newName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameScreen(currentName: _nameController.text),
      ),
    );
    if (newName != null && newName is String) {
      setState(() {
        _nameController.text = newName;
      });
    }
  }

  // "Bio" 탭 -> 새 화면
  Future<void> _navigateToBio() async {
    final newBio = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBioScreen(currentBio: _bioController.text),
      ),
    );
    if (newBio != null && newBio is String) {
      setState(() {
        _bioController.text = newBio;
      });
    }
  }

  // --- 레이아웃 Helper 위젯 (변경 없음) ---

  Widget _buildTappableLabelValue(
      {required String label,
      required String value,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: secondaryColor, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value.isEmpty ? ' ' : value,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Divider(thickness: 0.5, color: secondaryColor),
        ],
      ),
    );
  }

  Widget _buildStaticLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: secondaryColor, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        const Divider(thickness: 0.5, color: secondaryColor),
      ],
    );
  }

  Widget _buildTappableValue(String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Divider(thickness: 0.5, color: secondaryColor),
        ],
      ),
    );
  }

  Widget _buildTappableValueRow(
      String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Row(
                children: [
                  Text(value, style: const TextStyle(color: secondaryColor)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: secondaryColor, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 0.5, color: secondaryColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAndReturn,
            child: Text(
              'Done',
              style: TextStyle(
                color: _isSaving ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showProfilePicOptions,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _newProfilePicFile != null
                              ? FileImage(_newProfilePicFile!)
                              : null,
                          child: _newProfilePicFile == null
                              ? const Icon(Icons.person,
                                  size: 40, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => _showAvatarDialog(context),
                        // ⭐️ 5. 아바타 아이콘을 asset 대신 기본 아이콘으로 변경
                        // (이건 영상의 '사람 얼굴' 아이콘 대체입니다)
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[850],
                          child: const Icon(
                            Icons.face_retouching_natural,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _showProfilePicOptions,
                    child: const Text(
                      'Change profile picture',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 레이아웃 ---

            _buildTappableLabelValue(
              label: 'Name',
              value: _nameController.text,
              onTap: _navigateToName,
            ),

            _buildStaticLabelValue('Username', 'ta_junhyuk'),

            _buildTappableValue('Pronouns', () {}),

            _buildTappableLabelValue(
              label: 'Bio',
              value: _bioController.text,
              onTap: _navigateToBio,
            ),

            _buildTappableValue('Add link', () {}),

            _buildTappableValue('Add banners', () {}),

            _buildTappableValueRow('Gender', 'Prefer not to say', () {}),

            _buildTappableValueRow('Music', 'Add music to your profile', () {}),

            // --- 하단 링크 ---
            const SizedBox(height: 16),
            const Divider(thickness: 0.5, color: secondaryColor),
            const SizedBox(height: 16),

            const Text(
              'Switch to professional account',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Personal information settings',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
