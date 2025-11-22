import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // Mock Data & Scenario
import 'package:instagram/models/feed_item.dart'; // ⭐️ FeedItem 추가 (피드 갱신용)
import 'package:instagram/models/post_model.dart'; // Model
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

  // ⭐️ 로그인한 유저: 브라운 박사님 ('brown')
  final myUser = MOCK_USERS['brown']!;

  // ⭐️ 게시물 작성 완료 시 호출되는 함수
  void _addPost(File image, String caption) {
    setState(() {
      // 1. 새로운 PostModel 생성
      final newPost = PostModel(
        username: myUser.username,
        userProfilePicAsset: myUser.profilePicAsset,
        images: [image.path], // File 경로를 저장
        caption: caption,
        comments: [],
        likes: 0,
        date: DateTime.now(),
      );

      // 2. 내 프로필 데이터(posts)에 추가 (최신글이 맨 앞)
      myUser.posts.insert(0, newPost);

      // 3. ⭐️ [중요] 홈 피드 시나리오에도 추가해야 홈 화면에 뜸!
      HOME_FEED_SCENARIO.insert(
        0, // 맨 위에 추가
        FeedItem(type: FeedItemType.post, post: newPost),
      );

      // 4. 홈 탭(0)으로 이동해서 확인
      _selectedIndex = 0;
    });
  }

  // 탭 선택 처리
  void _onTabTapped(int index) async {
    if (index == 2) {
      // [Add 탭] 갤러리 -> 필터 -> 작성 -> 업로드 흐름
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

          // 작성이 완료되면 _addPost 호출
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
          const HomeScreen(), // 0: 홈 (시나리오 + 새 글)
          const SearchScreen(), // 1: 검색
          Container(), // 2: 추가 (로직은 위에서 처리됨)
          const ReelsScreen(), // 3: 릴스
          // ⭐️ 4: 내 프로필 (kid_go가 아니라 myUser(brown) 전달)
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
