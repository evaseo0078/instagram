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
  final myUser = MOCK_USERS['ta_junhyuk']!;
  List<PostModel> _feedPosts = [];

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  void _refreshFeed() {
    List<PostModel> tempPosts = [];
    tempPosts.addAll(myUser.posts);
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

  // 게시물 작성 완료 시 호출
  void _addPost(File image, String caption) {
    setState(() {
      MOCK_USERS['ta_junhyuk']!.posts.insert(
          0,
          PostModel(
            username: 'ta_junhyuk',
            userProfilePicAsset: 'assets/images/my_profile.png',
            images: [image],
            caption: caption,
            comments: [],
            likes: 0,
          ));
      _refreshFeed();
      _selectedIndex = 0;
    });
  }

  // 탭 선택 함수 수정
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
        // 상태 유지를 위해 IndexedStack 사용 권장
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          Container(), // 빈 컨테이너로 대체 (갤러리 픽커는 탭에서 직접 열림)
          const ReelsScreen(),
          ProfileScreen(user: MOCK_USERS['kid_go']!, isMyProfile: true),
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
