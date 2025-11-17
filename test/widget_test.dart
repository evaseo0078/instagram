// 📍 test/widget_test.dart (오류 수정)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:instagram/main.dart';
// ⭐️ 1. 'main_screen.dart' import 제거 (스크린샷 7번째 줄 오류)

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // ⭐️ 2. '0'이나 '1' 텍스트 대신,
    //    MainScreen의 BottomNavigationBar에 있는 'Home' 아이콘을 찾습니다.
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);

    // ⭐️ 3. 'Icons.add'를 탭하는 테스트는
    //    BottomNavigationBar의 'Add' 아이콘을 탭하는 것으로 변경합니다.
    await tester.tap(find.byIcon(Icons.add_box_outlined));
    await tester.pumpAndSettle(); // ⭐️ 바텀 시트가 올라오는 애니메이션 대기

    // ⭐️ 4. 'Create' 텍스트가 바텀 시트에 나타나는지 확인합니다.
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
  });
}
