import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart'; // 방금 만든 main_screen.dart 파일
import 'utils/colors.dart'; // 방금 만든 colors.dart 파일

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 앱의 기본 테마 설정
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0, // 상단바 그림자 제거
          systemOverlayStyle: SystemUiOverlayStyle.dark, // 상태바 아이콘 검은색
          iconTheme: IconThemeData(color: primaryColor),
          titleTextStyle: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainScreen(), // 우리의 메인 화면을 보여줍니다.
    );
  }
}
