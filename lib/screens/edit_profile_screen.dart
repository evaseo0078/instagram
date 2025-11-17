// 📍 lib/screens/edit_profile_screen.dart (아이콘, 정렬, 오타 수정 완료)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_bio_screen.dart';
import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:instagram/screens/edit_name_screen.dart';
import 'package:instagram/screens/gallery_picker_screen.dart';
import 'package:instagram/utils/colors.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
    _newProfilePicFile = widget.currentProfilePic;

    // (영상 03:34) 화면 로드 직후 팝업 띄우기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAvatarDialog(context);
    });
  }

  // (영상 03:34 / 스크린샷 image_54fa84.png) 아바타 팝업 (⭐️ 스크린샷과 일치하도록 수정)
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          // ⭐️ (영상/스크린샷) 팝업 가로 폭을 더 좁게
          insetPadding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: Container(
            // ⭐️ (스크린샷) 버튼 영역을 고려한 하단 패딩 (원본 0)
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/avatar_promo.png',
                  height: 100,
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
                // ⭐️ 1. (스크린샷) SizedBox(width: double.infinity) 부활
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
                // ⭐️ 2. (스크린샷) Divider 부활
                const Divider(
                  height: 1,
                  color: secondaryColor,
                  indent: 16, // 스크린샷과 유사하게 좌우 여백 적용
                  endIndent: 16,
                ),
                // ⭐️ 3. (스크린샷) SizedBox(width: double.infinity) 부활
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

  // "Done" 버튼 눌렀을 때
  void _saveAndReturn() {
    Navigator.of(context).pop({
      'name': _nameController.text,
      'bio': _bioController.text,
      'image': _newProfilePicFile,
    });
  }

  // (영상 03:38) 프로필 사진 변경 흐름
  Future<void> _pickImageFromGallery() async {
    Navigator.of(context).pop(); // 1. 바텀시트 닫기

    // 2. (영상 03:39) 갤러리 화면
    final File? originalFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GalleryPickerScreen(),
      ),
    );
    if (originalFile == null) return;

    // 3. (영상 03:41) 필터 화면
    final File? filteredFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFilterScreen(imageFile: originalFile),
      ),
    );
    if (filteredFile == null) return;

    // 4. (영상 03:42) 최종 이미지로 상태 업데이트
    setState(() {
      _newProfilePicFile = filteredFile;
    });
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
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[850],
                      child: Image.asset(
                        'assets/images/avatar_icon.png',
                        width: 40,
                        height: 40,
                        color: Colors.white, // 바텀시트에서는 흰색
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  // ⭐️ 1. (영상/피그마 기준) 아이콘 변경
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('Choose from library'),
                  onTap: _pickImageFromGallery, // ⭐️ 사진 변경 흐름 연결
                ),
                ListTile(
                  // ⭐️ 2. [TODO] 이 아이콘은 애셋 이미지로 변경해야 합니다.
                  //    (자세한 내용은 이전 채팅 답변 참고)
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
                    // ⭐️ 3. (영상 기준) textAlign: TextAlign.center 제거 (왼쪽 정렬)
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

  // --- 레이아웃 Helper 위젯 (영상/스크린샷 레이아웃/간격 최종본) ---

  // 패턴 1: Name, Bio
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

  // 패턴 2: Username
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

  // 패턴 3: Pronouns, Add link, Add banners
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

  // 패턴 4: Gender, Music
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
            onPressed: _saveAndReturn,
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
                        onTap: _showProfilePicOptions, // ⭐️ 사진 탭
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
                        onTap: () => _showAvatarDialog(context), // ⭐️ 아바타 탭
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[850],
                          child: Image.asset(
                            'assets/images/avatar_icon.png',
                            width: 40,
                            height: 40,
                            // 메인 화면에서는 틴트 없음 (원본 검은색)
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ⭐️ (스크린샷 image_54fd68.png / 영상 03:53 기준)
                  // ⭐️ 이모지(🔄) 없는 TextButton으로 다시 수정
                  TextButton(
                    onPressed: _showProfilePicOptions, // ⭐️ 텍스트 탭
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

            // ⭐️ 4. (오타 수정) _buildTallableValueRow -> _buildTappableValueRow
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
