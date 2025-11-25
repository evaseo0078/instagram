import 'dart:async';
import 'dart:io';
import 'dart:math'; // ⭐️ sin 함수용
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/services/llm_service.dart';
import 'package:instagram/utils/colors.dart';
import 'package:intl/intl.dart'; // ⭐️ 시간 포맷용 (pub add intl 필요)

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

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _isLlmTyping = false;

  @override
  void initState() {
    super.initState();
    // 초기 메시지 (Ran Mouri)
    if (widget.username == "Ran Mouri" || widget.username.contains("Ran")) {
      final now = DateTime.now();
      _messages.addAll([
        ChatMessage(
            text: "Nice to meet you!",
            isSentByMe: true,
            status: MessageStatus.seen,
            timestamp: now.subtract(const Duration(minutes: 20))),
        ChatMessage(
            text: "Hi!",
            isSentByMe: true,
            status: MessageStatus.seen,
            timestamp: now.subtract(const Duration(minutes: 21))),
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

    final newMessage = ChatMessage(
      text: text,
      isSentByMe: true,
      status: MessageStatus.sending,
      animate: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, newMessage);
    });

    // 전송 완료
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => newMessage.status = MessageStatus.sent);
      }
    });

    // 읽음 처리 후 LLM 호출
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          newMessage.status = MessageStatus.seen;
          _isLlmTyping = true;
        });
        _getLlmResponse(text);
      }
    });
  }

  Future<void> _getLlmResponse(String text) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // 타이핑 연출
      final response = await LlmService.getChatResponse(text);

      if (mounted) {
        setState(() {
          _isLlmTyping = false;
          _messages.insert(
              0,
              ChatMessage(
                text: response,
                isSentByMe: false,
                animate: true,
                timestamp: DateTime.now(),
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
              itemCount: _messages.length + (_isLlmTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLlmTyping && index == 0) {
                  return _buildTypingIndicator();
                }

                final msgIndex = _isLlmTyping ? index - 1 : index;
                final message = _messages[msgIndex];

                // 시간 표시 로직 (15분 간격)
                bool showTime = false;
                if (msgIndex == _messages.length - 1) {
                  showTime = true;
                } else {
                  final prevMessage = _messages[msgIndex + 1];
                  final difference = message.timestamp
                      .difference(prevMessage.timestamp)
                      .inMinutes;
                  if (difference > 15) showTime = true;
                }

                return _buildMessageBubble(message, msgIndex, showTime);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
              radius: 14, backgroundImage: AssetImage(widget.profilePicAsset)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(20)),
            child: const TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index, bool showTime) {
    final isMe = message.isSentByMe;
    final showSeen = isMe && message.status == MessageStatus.seen && index == 0;

    String formattedTime =
        "Today ${DateFormat('h:mm a').format(message.timestamp)}";

    return Column(
      children: [
        if (showTime)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(formattedTime,
                style: const TextStyle(color: secondaryColor, fontSize: 12)),
          ),
        Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 말풍선 애니메이션
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<Offset>(
                  begin: message.animate ? const Offset(-0.5, 0) : Offset.zero,
                  end: Offset.zero),
              curve: Curves.easeOut,
              builder: (context, Offset offset, child) {
                return Transform.translate(
                  offset: Offset(offset.dx * 50, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isMe) ...[
                    CircleAvatar(
                        radius: 14,
                        backgroundImage: AssetImage(widget.profilePicAsset)),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    // ⭐️ 오버플로우 방지: 화면 너비의 65%로 제한
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF3797EF)
                          : const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16),
                    ),
                  ),
                  if (isMe && message.status == MessageStatus.sending)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(CupertinoIcons.paperplane,
                          size: 16, color: secondaryColor),
                    ),
                ],
              ),
            ),

            // 내가 보낸 메시지 상태 (Seen 등)
            if (showSeen || (isMe && message.text == "Nice to meet you!"))
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 8),
                child: Text(
                    message.text == "Nice to meet you!"
                        ? "Seen"
                        : "Seen just now",
                    style:
                        const TextStyle(color: secondaryColor, fontSize: 12)),
              ),

            // ⭐️ [수정] Tap and hold to react 로직
            // 1. 받은 메시지여야 함 (!isMe)
            // 2. 가장 최신 메시지여야 함 (index == 0)
            // 3. LLM이 타이핑 중이 아니어야 함 (!_isLlmTyping) -> 이건 리스트 구조상 자연스럽게 처리됨
            if (!isMe && index == 0)
              const Padding(
                padding: EdgeInsets.only(left: 40, top: 4, bottom: 8),
                child: Text("Tap and hold to react",
                    style: TextStyle(color: secondaryColor, fontSize: 10)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 8),
      child: Row(
        children: [
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Color(0xFF3797EF), shape: BoxShape.circle),
              child: const Icon(Icons.search, color: Colors.white, size: 24),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Color(0xFF3797EF), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.camera_fill,
                  color: Colors.white, size: 22),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12)),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isTyping)
            GestureDetector(
              onTap: _sendMessage,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Send",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            )
          else
            // ⭐️ 오버플로우 방지: 아이콘 사이즈와 간격 미세 조정
            Row(
              children: const [
                Icon(CupertinoIcons.mic, size: 26),
                SizedBox(width: 8),
                Icon(CupertinoIcons.photo, size: 26),
                SizedBox(width: 8),
                Icon(CupertinoIcons.smiley, size: 26),
                SizedBox(width: 8),
                Icon(CupertinoIcons.add_circled, size: 26),
              ],
            ),
        ],
      ),
    );
  }
}

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});
  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double y = -3 *
                  (0.5 + 0.5 * sin(index * 1.5 + _controller.value * 6.28));
              return Transform.translate(
                offset: Offset(0, y),
                child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle)),
              );
            },
          );
        }),
      ),
    );
  }
}
