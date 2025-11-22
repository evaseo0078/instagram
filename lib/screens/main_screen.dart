import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // Mock Data
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

  // ⭐️ 현재 로그인한 유저 (ta_junhyuk)
  final myUser = MOCK_USERS['ta_junhyuk']!;

  // ⭐️ 전체 피드 게시물 리스트 (내꺼 + 팔로우한 사람꺼)
  List<PostModel> _feedPosts = [];

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  // ⭐️ 피드 새로고침 (데이터 갱신)
  void _refreshFeed() {
    List<PostModel> tempPosts = [];

    // 1. 내 게시물 추가
    tempPosts.addAll(myUser.posts);

    // 2. 팔로우한 사람들의 게시물 추가
    for (var followingUsername in myUser.followingUsernames) {
      final user = MOCK_USERS[followingUsername];
      if (user != null) {
        tempPosts.addAll(user.posts);
      }
    }

    setState(() {
      _feedPosts = tempPosts;
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

  // ⭐️ 게시물 작성 후 콜백
  void _addPost(File image, String caption) {
    setState(() {
      // 내 유저 데이터에 게시물 추가
      myUser.posts.add(PostModel(
        username: myUser.username,
        userProfilePicAsset: myUser.profilePicAsset,
        image: image,
        caption: caption,
        comments: [],
        likes: 0,
      ));

      // 피드 갱신 및 프로필 탭으로 이동
      _refreshFeed();
      _selectedIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // 상태 유지를 위해 IndexedStack 사용 권장
        index: _selectedIndex,
        children: [
          HomeScreen(allPosts: _feedPosts), // 0: 홈 (피드)
          const SearchScreen(), // 1: 검색 (다른 유저 찾기)
          Container(), // 2: 추가 (바텀시트)
          const ReelsScreen(), // 3: 릴스
          ProfileScreen(
            // 4: 내 프로필
            user: myUser,
            isMyProfile: true,
          ),
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

  // --- (아래는 기존 _showCreatePostSheet 등 복사해서 사용) ---
  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                      borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: 16),
              const Text('Create',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                  leading: const Icon(Icons.grid_on_outlined),
                  title: const Text('Post'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageAndNavigate();
                  }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageAndNavigate() async {
    final File? originalFile = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const GalleryPickerScreen()));
    if (originalFile == null) return;
    final File? filteredFile = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditFilterScreen(imageFile: originalFile)));
    if (filteredFile == null) return;
    final String? caption = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPostScreen(imageFile: filteredFile)));
    if (caption != null) {
      _addPost(filteredFile, caption);
    }
  }
}
