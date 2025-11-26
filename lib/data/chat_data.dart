// 📍 lib/data/chat_data.dart

import 'package:instagram/models/chat_message.dart';

class ChatData {
  static final Map<String, List<ChatMessage>> chats = {
    // 1. Heiji Hattori (inseong)
    'Heiji Hattori': [
      // ⭐️ 내가 보낸 최신 메시지 "Good!" 추가 (아직 안 읽음)
      ChatMessage(
        text: "Good!",
        isSentByMe: true,
        status: MessageStatus.sent, // 읽음(Seen) 아님
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      // 3분 전 (Heiji가 보낸 것)
      ChatMessage(
        text: "I stole the jewel! 💎",
        isSentByMe: false,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      // 1달 전
      ChatMessage(
        text: "See you next month.",
        isSentByMe: false,
        status: MessageStatus.seen,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ],

    // 2. Conan Edogawa (그대로)
    'Conan Edogawa': [
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
