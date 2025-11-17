// 📍 lib/screens/edit_profile_screen.dart (레이아웃 수정 최종본)

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAvatarDialog(context);
    });
  }

  // (아바타 팝업은 이전과 동일)
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double dialogWidth = MediaQuery.of(context).size.width * 0.5;
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          insetPadding: EdgeInsets.symmetric(
              horizontal:
                  (MediaQuery.of(context).size.width - dialogWidth) / 2),
          child: Container(
            width: dialogWidth,
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
                  'Get your own personalized\nstickers to share in stories and\n chats.',
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
                const Divider(height: 1, color: secondaryColor),
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

  void _saveAndReturn() {
    Navigator.of(context).pop({
      'name': _nameController.text,
      'bio': _bioController.text,
      'image': _newProfilePicFile,
    });
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.of(context).pop();

    final File? originalFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GalleryPickerScreen(),
      ),
    );
    if (originalFile == null) return;

    final File? filteredFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFilterScreen(imageFile: originalFile),
      ),
    );
    if (filteredFile == null) return;

    setState(() {
      _newProfilePicFile = filteredFile;
    });
  }

  // (바텀시트는 이전과 동일)
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
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from library'),
                  onTap: _pickImageFromGallery,
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
                    textAlign: TextAlign.center,
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

  // (Name 화면 이동은 이전과 동일)
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

  // (Bio 화면 이동은 이전과 동일)
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

  // ⭐️ --- (이하 Helper 위젯 전체 수정) --- ⭐️

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
          const SizedBox(height: 2), // ⭐️ 간격 수정
          Text(value, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8), // ⭐️ 간격 수정
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
          // ⭐️ 라벨이 없으므로 값만 표시 (패딩용 빈 컨테이너 추가)
          const SizedBox(height: 14), // 라벨+SizedBox 높이와 비슷하게
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
          const SizedBox(height: 14), // ⭐️ 간격 추가
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
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[850],
                          child: Image.asset(
                            'assets/images/avatar_icon.png',
                            width: 40,
                            height: 40,
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

            // ⭐️ --- (이하 build 메소드 레이아웃 전체 수정) --- ⭐️

            // Name (패턴 1)
            _buildTappableLabelValue(
              label: 'Name',
              value: _nameController.text, // ⭐️ 컨트롤러 값 사용
              onTap: _navigateToName,
            ),
            // ⭐️ Sizedbox 간격 제거 -> 위젯 자체에 간격 포함됨

            // Username (패턴 2)
            _buildStaticLabelValue('Username', 'ta_junhyuk'),

            // Pronouns (패턴 3)
            _buildTappableValue('Pronouns', () {}),

            // Bio (패턴 1)
            _buildTappableLabelValue(
              label: 'Bio',
              value: _bioController.text, // ⭐️ 컨트롤러 값 사용
              onTap: _navigateToBio,
            ),

            // Add link (패턴 3)
            _buildTappableValue('Add link', () {}),

            // Add banners (패턴 3)
            _buildTappableValue('Add banners', () {}),

            // Gender (패턴 4)
            _buildTappableValueRow('Gender', 'Prefer not to say', () {}),

            // Music (패턴 4)
            _buildTappableValueRow('Music', 'Add music to your profile', () {}),

            // ⭐️ 간격/구분선 수정
            const SizedBox(height: 16),
            const Divider(thickness: 0.5, color: secondaryColor),
            const SizedBox(height: 16),

            // Bottom Links
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
