import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart'; // 방금 만든 main_screen.dart 파일
import 'utils/colors.dart'; // 방금 만든 colors.dart 파일
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
          iconTheme: IconThemeData(color: primaryColor),
          titleTextStyle: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      home: const MainScreen(), // 우리의 메인 화면을 보여줍니다.
    );
  }
}
