// 📍 lib/data/chat_data.dart

import 'package:instagram/models/chat_message.dart';

class ChatData {
  static final Map<String, List<ChatMessage>> chats = {
    // 1. Kaito Kid (kid_go)
    'Kaito Kid': [
      // ⭐️ 1시간 전 -> 3분 전으로 수정
      ChatMessage(
        text: "I stole the jewel! 💎",
        isSentByMe: false,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      // 1달 전 메시지
      ChatMessage(
        text: "See you next month.",
        isSentByMe: false,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ],

    // 2. Ran Mouri (그대로)
    'Ran Mouri': [
      ChatMessage(
        text: "Nice to meet you!",
        isSentByMe: true,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      ChatMessage(
        text: "Hi!",
        isSentByMe: true,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(minutes: 21)),
      ),
    ],
  };

  static List<ChatMessage> getMessages(String username) {
    if (!chats.containsKey(username)) {
      chats[username] = [];
    }
    return chats[username]!;
  }
}
