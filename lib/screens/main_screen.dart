// 📍 lib/screens/main_screen.dart (전체 덮어쓰기)

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:instagram/screens/gallery_picker_screen.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/reels_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final myUser = MOCK_USERS['brown']!;

  void _addPost(File image, String caption) {
    setState(() {
      // 1. 새 게시물
      final newPost = PostModel(
        username: myUser.username,
        userProfilePicAsset: myUser.profilePicAsset,
        images: [image.path],
        caption: caption,
        comments: [],
        likes: 0,
        date: DateTime.now(),
      );

      // 2. 데이터 추가
      myUser.posts.insert(0, newPost);
      HOME_FEED_SCENARIO.insert(
          0, FeedItem(type: FeedItemType.post, post: newPost));

      // 3. 홈으로 이동
      _selectedIndex = 0;

      // ⭐️ 4. [자동 댓글] 5초 뒤 Conan
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            newPost.likes++;
            newPost.comments.add({
              "username": "conan",
              "comment": "Wow! Awesome photo! 🔥",
              "time": "Just now",
              "isLiked": false,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('conan commented: "Wow! Awesome photo! 🔥"'),
                duration: Duration(seconds: 2)),
          );
        }
      });
    });
  }

  void _onTabTapped(int index) async {
    if (index == 2) {
      final File? originalFile = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GalleryPickerScreen()),
      );

      if (originalFile != null) {
        if (!mounted) return;
        final File? filteredFile = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditFilterScreen(imageFile: originalFile)),
        );

        if (filteredFile != null && mounted) {
          final String? caption = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPostScreen(imageFile: filteredFile)),
          );

          if (caption != null) {
            _addPost(filteredFile, caption);
          }
        }
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          Container(),
          const ReelsScreen(),
          // 내 프로필 전달
          ProfileScreen(user: myUser, isMyProfile: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_creation_outlined),
              activeIcon: Icon(Icons.movie_creation),
              label: 'Reels'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
