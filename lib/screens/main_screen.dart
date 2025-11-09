// Cupertino 아이콘(iOS 스타일)을 위해 추가
import 'package:flutter/material.dart';
import 'add_post_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reels_screen.dart';
import 'search_screen.dart';
import '../utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스

  // 하단 탭에 따라 보여줄 화면 리스트
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const ReelsScreen(),
    const ProfileScreen(),
  ];

  // 탭이 선택되었을 때 호출될 함수
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 본문 (선택된 탭에 따라 화면이 바뀜)
      body: _screens[_selectedIndex],

      // 2. 하단 내비게이션 바
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
        currentIndex: _selectedIndex, // 현재 선택된 인덱스
        selectedItemColor: primaryColor, // 선택된 아이콘 색상
        unselectedItemColor: secondaryColor, // 선택되지 않은 아이콘 색상
        onTap: _onTabTapped, // 탭 클릭 시 _onTabTapped 함수 호출
        backgroundColor: backgroundColor, // 배경색
        type: BottomNavigationBarType.fixed, // 탭이 고정되도록
        showSelectedLabels: false, // 선택된 라벨 숨기기
        showUnselectedLabels: false, // 선택되지 않은 라벨 숨기기
        elevation: 0, // 그림자 제거
      ),
    );
  }
}
