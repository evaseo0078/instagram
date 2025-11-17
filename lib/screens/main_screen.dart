// 📍 lib/screens/main_screen.dart (오타 수정 + 샘플 이미지 + image_picker)

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/reels_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/utils/colors.dart';

import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:instagram/screens/gallery_picker_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _allPosts = [
    {
      "username": "aespa_official",
      "caption": "Spicy! 🔥",
      "imagePath": 'https://placehold.co/600x600/E8D3D3/000000?text=aespa',
      "commentsList": <Map<String, dynamic>>[],
    },
    {
      "username": "ta_junhyuk",
      "caption": "I love puang",
      "imagePath": 'https://placehold.co/600x600/D3E8D3/000000?text=Puang',
      "commentsList": [
        {
          "username": "ta_junhyuk",
          "comment": "I love puang",
          "time": "1s ago",
          "isLiked": false,
        }
      ],
    }
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(allPosts: _allPosts),
      const SearchScreen(),
      Container(),
      const ReelsScreen(),
      ProfileScreen(
        allPosts: _allPosts,
        onAddPostPressed: () => _showCreatePostSheet(context),
      ),
    ];
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // ⭐️⭐️⭐️ 오타 수정! (image_6314e9.png) ⭐️⭐️⭐️
      // RoundedRectangleBorderrtical -> RoundedRectangleBorder
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: backgroundColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Create',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.movie_creation_outlined),
                title: const Text('Reel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_on_outlined),
                title: const Text('Post'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageAndNavigate();
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_view_outlined),
                title: const Text('Share only to profile'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageAndNavigate() async {
    // 1. (영상 1:46) 'GalleryPickerScreen'을 띄움 (image_picker 사용)
    final File? originalFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GalleryPickerScreen(),
      ),
    );
    if (originalFile == null) return;

    // 2. (영상 1:53) 'EditFilterScreen'을 띄움 (가짜 필터 UI)
    final File? filteredFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFilterScreen(imageFile: originalFile),
      ),
    );
    if (filteredFile == null) return;

    // 3. (영상 2:00) 'AddPostScreen'으로 파일 전달
    final String? caption = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(imageFile: filteredFile),
      ),
    );

    // 4. (영상 2:09) "Share"를 누르고 돌아왔다면
    if (caption != null) {
      _addPost(filteredFile, caption);
    }
  }

  void _addPost(File image, String caption) {
    setState(() {
      _allPosts.add({
        "username": "ta_junhyuk",
        "caption": caption,
        "imagePath": image, // File 객체로 저장
        "commentsList": <Map<String, dynamic>>[],
      });
      _selectedIndex = 4;
    });
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _showCreatePostSheet(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_creation_outlined),
            activeIcon: Icon(Icons.movie_creation),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
        onTap: _onTabTapped,
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
      ),
    );
  }
}
