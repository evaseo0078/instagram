// dm 관련
// 📍 lib/models/chat_message.dart (신규 파일)
import 'dart:io';

enum MessageStatus { sending, sent, seen }

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final File? imageFile;
  MessageStatus status;
  final bool animate;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    this.imageFile,
    this.status = MessageStatus.sent,
    this.animate = false,
    required this.timestamp,
  });
}
