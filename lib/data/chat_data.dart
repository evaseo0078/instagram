// dm 관련
// 📍 lib/data/chat_data.dart (신규 파일)
import 'package:instagram/models/chat_message.dart';

class ChatData {
  // 유저 이름(username)을 키(Key)로 사용하여 대화 목록을 저장합니다.
  static final Map<String, List<ChatMessage>> chats = {
    // 1. Kaito Kid (kid_go) 데이터 설정
    'Kaito Kid': [
      // 1시간 전 메시지 (최신)
      ChatMessage(
        text: "I stole the jewel! 💎",
        isSentByMe: false,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)), // 1시간 전
      ),
      // 1달 전 메시지
      ChatMessage(
        text: "See you next month.",
        isSentByMe: false,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(days: 30)), // 30일 전
      ),
    ],

    // 2. Ran Mouri 데이터 설정
    'Ran Mouri': [
      // 20분 전
      ChatMessage(
        text: "Nice to meet you!",
        isSentByMe: true,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      // 21분 전
      ChatMessage(
        text: "Hi!",
        isSentByMe: true,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(minutes: 21)),
      ),
    ],
  };

  // 특정 유저의 메시지 가져오기 (없으면 빈 리스트 생성)
  static List<ChatMessage> getMessages(String username) {
    if (!chats.containsKey(username)) {
      chats[username] = [];
    }
    return chats[username]!;
  }
}
