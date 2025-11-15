// 📍 lib/screens/edit_profile_screen.dart (영상 반영 최종본)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

    // (영상 03:34) 화면 로드 직후 팝업 띄우기 (이전과 동일)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAvatarDialog(context);
    });
  }

  // (영상 03:34) "Create your avatar" 팝업 (이전과 동일)
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get your own personalized stickers to share in stories and chats.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: secondaryColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create avatar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Not now',
                      style: TextStyle(color: primaryColor),
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newProfilePicFile = File(image.path);
      });
    }
  }

  // ⭐️ 1. (영상 03:37) 프로필 사진 옵션 바텀시트 (UI 수정됨)
  void _showProfilePicOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16), // ⭐️
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // ⭐️ 2. (영상 03:37 / image_eb412d.png) 상단 사진 2개 추가
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
                    backgroundColor: Colors.grey[850], // ⭐️
                    child: const Icon(Icons.tag_faces_outlined, // ⭐️
                        size: 32,
                        color: Colors.white),
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
                // ⭐️ (영상 03:38) 페이스북 아이콘 (가장 근접한 표준 아이콘)
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

              // ⭐️ 3. (영상 03:38 / image_eb412d.png) 하단 텍스트 추가
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
                        // ⭐️ 여기에 'onTap' 핸들러를 추가하여 링크로 만들 수 있습니다.
                        // recognizer: TapGestureRecognizer()..onTap = () { ... }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // (Helper 위젯들은 이전과 동일)
  Widget _buildTextField(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: secondaryColor, fontSize: 12)),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: secondaryColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRow(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: secondaryColor),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildValueRow(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: secondaryColor)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: secondaryColor),
        ],
      ),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStaticRow(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ⭐️ 4. "Cancel" 텍스트 -> "뒤로가기 화살표" (영상 03:40)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ⭐️ 5. "centerTitle: false"로 왼쪽 정렬 (영상 03:40)
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
                      // ⭐️ 6. (영상 03:37) 왼쪽 사진에 클릭 이벤트 추가
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
                      // ⭐️ 7. (영상 03:36) 오른쪽 아바타에 클릭 이벤트 + UI 수정
                      GestureDetector(
                        onTap: () => _showAvatarDialog(context),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[850], // ⭐️
                          child: const Icon(Icons.tag_faces_outlined, // ⭐️
                              size: 40,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ⭐️ 8. (영상 03:37) 텍스트 버튼에도 클릭 이벤트 유지
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

            // (이하 레이아웃은 이전과 동일)
            _buildTextField(label: 'Name', controller: _nameController),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Username',
                    style: TextStyle(color: secondaryColor, fontSize: 12)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'ta_junhyuk',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const Divider(thickness: 0.5, color: secondaryColor),
              ],
            ),
            const SizedBox(height: 8),
            _buildStaticRow('Pronouns'),
            const SizedBox(height: 8),
            _buildTextField(label: 'Bio', controller: _bioController),
            const SizedBox(height: 16),
            _buildStaticRow('Add link'),
            _buildStaticRow('Add banners'),
            _buildValueRow('Gender', 'Prefer not to say'),
            _buildValueRow('Music', 'Add music to your profile'),
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
