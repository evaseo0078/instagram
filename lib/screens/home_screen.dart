import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// svg import removed: using png asset instead
import '../widgets/post_widget.dart'; // ⭐️ 방금 만든 PostWidget import (필수)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 상단 앱 바 (AppBar)
      appBar: AppBar(
        // ⭐️ PNG 로고를 사용하는 코드로 변경
        title: Image.asset(
          'assets/images/ic_instagram_logo.png', // ⭐️ PNG 파일 경로
          height: 32,
          // ⭐️ PNG는 색상을 코드로 바꿀 수 없으므로,
          // ⭐️ 라이트/다크 모드에 맞는 로고 이미지를 준비해야 합니다.
          // ⭐️ 지금은 primaryColor(검은색)와 배경색(흰색)이 잘 어울릴 겁니다.
        ),
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.heart), onPressed: () {}),
          IconButton(
            icon: const Icon(CupertinoIcons.paperplane),
            onPressed: () {},
          ),
        ],
      ),

      // 2. 본문 (스크롤되는 피드)
      body: ListView.builder(
        itemCount: 5, // 임시로 5개의 게시물
        itemBuilder: (context, index) {
          // ⭐️ 임시 회색 박스 대신 PostWidget을 반환합니다.
          return const PostWidget();
        },
      ),
    );
  }
}
