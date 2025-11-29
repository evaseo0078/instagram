import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
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
  late final myUser = MOCK_USERS['brown']!;
  bool _showPostedNotification = false;
  File? _lastPostedImage;

  @override
  void initState() {
    super.initState();
    // myUser는 late final로 선언했으므로 여기서 사용 가능
  }

  void _goToHomeWithNotification() {
    setState(() {
      _selectedIndex = 0; // 홈 이동
      _showPostedNotification = true;
    });

    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showPostedNotification = false);
    });

    Timer(const Duration(seconds: 5), () {
      if (mounted && myUser.posts.isNotEmpty) {
        setState(() {
          final recentPost = myUser.posts.first;
          recentPost.likes++;
          recentPost.comments.add({
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
  }

  void _handleUploadComplete(String imagePath, String caption) {
    print('🚀🚀🚀 Uploading post in MainScreen (callback)');

    final uploadedFile = File(imagePath);

    final newPost = PostModel(
      username: myUser.username,
      userProfilePicAsset: myUser.profilePicAsset,
      images: [imagePath],
      caption: caption,
      comments: [],
      likes: 0,
      isLiked: false,
      date: DateTime.now(),
    );

    setState(() {
      _lastPostedImage = uploadedFile;
      myUser.posts.insert(0, newPost);
      HOME_FEED_SCENARIO.insert(
        0,
        FeedItem(
          type: FeedItemType.post,
          post: newPost,
        ),
      );
    });

    print('🚀🚀🚀 Post uploaded, going to home');
    _goToHomeWithNotification();
  }

  void _onTabTapped(int index) async {
    print('🚀🚀🚀 NEW MAIN_SCREEN CODE - Tab tapped: $index');

    // + 버튼(index 2) 클릭 시 프로필로 이동하고 업로드 플로우 시작
    if (index == 2) {
      print('🚀🚀🚀 Redirecting to Profile for upload');
      // 프로필 화면으로 이동 (업로드 완료는 콜백으로 처리)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            user: myUser,
            isMyProfile: true,
            onUploadComplete: _handleUploadComplete,
          ),
        ),
      );
      return;
    }

    print('🚀🚀🚀 Normal tab switch to: $index');
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
              showPostedNotification: _showPostedNotification,
              postedImage: _lastPostedImage),
          const SearchScreen(),
          Container(),
          const ReelsScreen(),
          ProfileScreen(
              user: myUser,
              isMyProfile: true,
              onUploadComplete: _handleUploadComplete), // 일반 탭에서도 콜백 전달
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
