import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ⭐️ 'image_picker'는 이제 사용하지 않습니다. (삭제해도 됨)
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/reels_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/utils/colors.dart';

import 'package:instagram/screens/edit_filter_screen.dart';
// (path_provider도 import 해야 할 수 있습니다.)
import 'package:path_provider/path_provider.dart';

// ⭐️ 1. 방금 만든 'gallery_picker_screen.dart' import (필수!)
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
      "imagePath": null,
      "commentsList": <Map<String, dynamic>>[],
    },
    {
      "username": "ta_junhyuk",
      "caption": "I love puang",
      "imagePath": null,
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

  // ( ... _MainScreenState 클래스 내부 ... )

  // ( ... _MainScreenState 클래스 내부 ... )

  // // ⭐️ 9. (영상 1:42) "Create" 바텀시트 (UI 디테일 수정 최종본)
  // void _showCreatePostSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     // ⭐️ 1. 모서리를 둥글게 (영상과 일치)
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     backgroundColor: backgroundColor,
  //     builder: (context) {
  //       return Container(
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // ⭐️ 2. (영상 image_7ebca5.png) "Create" 위 드래그 핸들 추가
  //             Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[400],
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             const Text('Create',
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  //             const SizedBox(height: 16),

  //             // ⭐️ 3. 아이콘 수정 (영상 image_7ebc88.png)
  //             ListTile(
  //               // (Reel 아이콘)
  //               leading: const Icon(Icons.movie_creation_outlined),
  //               title: const Text('Reel'),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),

  //             ListTile(
  //               // (Post 아이콘 - 3x3 그리드)
  //               leading: const Icon(Icons.grid_on_outlined),
  //               title: const Text('Post'),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 _pickImageAndNavigate();
  //               },
  //             ),

  //             ListTile(
  //               // (Share 아이콘 - 2x2 그리드)
  //               // (영상 속 2x2 + '+' 아이콘은 인스타그램 커스텀 아이콘이라
  //               // 표준 아이콘 중 가장 비슷한 2x2 그리드로 대체합니다.)
  //               leading: const Icon(Icons.grid_view_outlined),
  //               title: const Text('Share only to profile'),

  //               // ⭐️ 4. "New" 태그 배지 (영상 image_7ebcaa.png)
  //               trailing: Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                 decoration: BoxDecoration(
  //                   color: Colors.blue,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: const Text(
  //                   'New',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  // ( ... _MainScreenState 클래스 내부 ... )

  // ⭐️ 9. (영상 1:42) "Create" 바텀시트 (아이콘 최종 수정본)
  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
              // (드래그 핸들)
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

              // ⭐️ 1. "Reel" (가장 비슷한 Material 아이콘)
              ListTile(
                leading: const Icon(Icons.movie_creation_outlined),
                title: const Text('Reel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

              // ⭐️ 2. "Post" (영상과 동일한 3x3 그리드)
              ListTile(
                leading: const Icon(Icons.grid_on_outlined),
                title: const Text('Post'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageAndNavigate();
                },
              ),

              // ⭐️ 3. "Share only to profile" (가장 비슷한 2x2 그리드)
              ListTile(
                leading: const Icon(Icons.grid_view_outlined),
                title: const Text('Share only to profile'),

                // ("New" 태그 배지)
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

// ( ... _pickImageAndNavigate, _addPost 등 나머지 함수는 그대로 ... )

// ( ... _pickImageAndNavigate, _addPost 등 나머지 함수는 그대로 ... )

// ( ... _pickImageAndNavigate, _addPost 등 나머지 함수는 그대로 ... )

  // ⭐️ 2. 갤러리/포스팅 로직 (수정된 최종본)
  Future<void> _pickImageAndNavigate() async {
    // 1. (영상 1:46) 'GalleryPickerScreen'을 띄움
    final File? originalFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GalleryPickerScreen(),
      ),
    );

    if (originalFile == null) return; // 갤러리에서 취소

    // ⭐️ 3. (영상 1:53) 'EditFilterScreen'을 띄움 (새로 추가된 단계)
    // ⭐️    원본 파일(originalFile)을 전달
    final File? filteredFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFilterScreen(imageFile: originalFile),
      ),
    );

    if (filteredFile == null) return; // 필터 화면에서 취소

    // ⭐️ 4. (영상 2:00) 'AddPostScreen'으로 "필터 적용된" 파일 전달
    final String? caption = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(imageFile: filteredFile), // ⭐️
      ),
    );

    // 5. (영상 2:09) 캡션 화면에서 "Share"를 누르고 돌아왔다면
    if (caption != null) {
      _addPost(filteredFile, caption); // ⭐️ "필터 적용된" 파일로 포스트
    }
  }

  // ⭐️ 3. "중앙 리스트"에 새 포스트 추가 (setState)
  void _addPost(File image, String caption) {
    setState(() {
      _allPosts.add({
        "username": "ta_junhyuk",
        "caption": caption,
        "imagePath": image,
        "commentsList": <Map<String, dynamic>>[],
      });
      // ⭐️ (영상 02:10) 포스팅 후 홈(0)이 아닌 프로필(4)로 이동
      _selectedIndex = 4;
    });
  }

  // ⭐️ 4. 탭 선택 로직
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
