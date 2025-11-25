import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/services/llm_service.dart';
import 'package:instagram/utils/colors.dart';

enum MessageStatus { sending, sent, seen }

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final File? imageFile;
  MessageStatus status;
  final bool animate;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    this.imageFile,
    this.status = MessageStatus.sent,
    this.animate = false,
  });
}

class ChatScreen extends StatefulWidget {
  final String username;
  final String profilePicAsset;

  const ChatScreen({
    super.key,
    required this.username,
    required this.profilePicAsset,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _isLlmTyping = false; // LLM 타이핑 중인지

  @override
  void initState() {
    super.initState();
    // 초기 메시지 (Ran Mouri)
    if (widget.username == "Ran Mouri" || widget.username.contains("Ran")) {
      _messages.addAll([
        ChatMessage(
            text: "Nice to meet you!",
            isSentByMe: true,
            status: MessageStatus.seen),
        ChatMessage(text: "Hi!", isSentByMe: true, status: MessageStatus.seen),
      ]);
    }
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.isEmpty) return;

    _messageController.clear();

    // 1. 내 메시지 추가 (비행기 표시)
    final newMessage = ChatMessage(
        text: text,
        isSentByMe: true,
        status: MessageStatus.sending,
        animate: true);

    setState(() {
      _messages.insert(0, newMessage);
    });

    // 2. 전송 완료 (비행기 사라짐) -> 1초 뒤
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          newMessage.status = MessageStatus.sent;
        });
      }
    });

    // 3. 읽음 처리 (Seen) 및 LLM 응답 요청 -> 2초 뒤
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          newMessage.status = MessageStatus.seen;
          _isLlmTyping = true; // 상대방 입력중 표시
        });
        // ⭐️ LLM 호출 (여기서 호출해야 답변이 옴)
        _getLlmResponse(text);
      }
    });
  }

  // ⭐️ LLM 응답 받기
  Future<void> _getLlmResponse(String text) async {
    try {
      final response = await LlmService.getChatResponse(text);

      if (mounted) {
        setState(() {
          _isLlmTyping = false; // 입력중 표시 끄기
          // LLM 메시지 추가 (왼쪽 말풍선)
          _messages.insert(
              0,
              ChatMessage(
                text: response,
                isSentByMe: false,
                animate: true, // 스르륵 등장
              ));
        });
      }
    } catch (e) {
      print("LLM Error: $e");
      if (mounted) setState(() => _isLlmTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.profilePicAsset),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor)),
                Text(widget.username,
                    style:
                        const TextStyle(fontSize: 12, color: secondaryColor)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(CupertinoIcons.phone, color: primaryColor),
              onPressed: () {}),
          IconButton(
              icon:
                  const Icon(CupertinoIcons.video_camera, color: primaryColor),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index], index);
              },
            ),
          ),
          // ⭐️ 상대방 입력중 (Typing...) 애니메이션
          if (_isLlmTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage(widget.profilePicAsset),
                  ),
                  const SizedBox(width: 8),
                  const Text("Typing...",
                      style: TextStyle(color: secondaryColor, fontSize: 12)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isMe = message.isSentByMe;
    final showSeen = isMe && message.status == MessageStatus.seen && index == 0;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // ⭐️ 애니메이션: 왼쪽에서 오른쪽으로 (Slide)
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<Offset>(
              begin: message.animate
                  ? const Offset(-0.5, 0) // 왼쪽에서 시작
                  : Offset.zero,
              end: Offset.zero),
          curve: Curves.easeOut,
          builder: (context, Offset offset, child) {
            return Transform.translate(
              offset: Offset(offset.dx * 50, 0), // X축 이동
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
            children: [
              // 말풍선
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isMe ? const Color(0xFF3797EF) : const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),

              // ⭐️ 비행기 아이콘 (말풍선 오른쪽)
              if (isMe && message.status == MessageStatus.sending)
                const Padding(
                  padding: EdgeInsets.only(left: 8), // 말풍선과 간격
                  child: Icon(CupertinoIcons.paperplane,
                      size: 16, color: secondaryColor),
                ),
            ],
          ),
        ),

        if (showSeen || (isMe && message.text == "Nice to meet you!"))
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Text(
              message.text == "Nice to meet you!" ? "Seen" : "Seen just now",
              style: const TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 8),
      child: Row(
        children: [
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF3797EF), // 파란색 돋보기 배경
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 24),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF3797EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.camera_fill,
                  color: Colors.white, size: 22),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isTyping)
            GestureDetector(
              onTap: _sendMessage,
              child: const Text(
                "Send",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            )
          else
            Row(
              children: const [
                Icon(CupertinoIcons.mic, size: 28),
                SizedBox(width: 12),
                Icon(CupertinoIcons.photo, size: 28),
                SizedBox(width: 12),
                Icon(CupertinoIcons.smiley, size: 28),
                SizedBox(width: 12),
                Icon(CupertinoIcons.add_circled, size: 28),
              ],
            ),
        ],
      ),
    );
  }
}
