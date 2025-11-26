// 📍 lib/screens/chat_screen.dart (전체 덮어쓰기)

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/services/llm_service.dart';
import 'package:instagram/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:instagram/models/chat_message.dart';
import 'package:instagram/data/chat_data.dart';

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
  late List<ChatMessage> _messages;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _isLlmTyping = false;

  // ⭐️ 5초 타이머를 위한 상태 변수
  bool _showReactHint = false;

  @override
  void initState() {
    super.initState();
    _messages = ChatData.getMessages(widget.username);
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

    // 내가 메시지를 보내면 힌트는 무조건 사라짐
    setState(() {
      _showReactHint = false;
    });

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

    Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => newMessage.status = MessageStatus.sent);
    });

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
      await Future.delayed(const Duration(seconds: 2));
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
          // ⭐️ 답변 오면 힌트 보여주기
          _showReactHint = true;
        });

        // ⭐️ 5초 뒤에 힌트 끄기
        Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showReactHint = false;
            });
          }
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // 패딩 조정
              itemCount: _messages.length + (_isLlmTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLlmTyping && index == 0) {
                  return _buildTypingIndicator();
                }

                final msgIndex = _isLlmTyping ? index - 1 : index;
                final message = _messages[msgIndex];

                // 15분 시간 표시 로직
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

                // ⭐️ 말풍선 그룹화 로직 (위/아래 메시지 확인)
                // 리스트가 reverse이므로:
                // index + 1 은 "이전(과거) 메시지" -> 말풍선 위쪽 모양 결정
                // index - 1 은 "다음(최신) 메시지" -> 말풍선 아래쪽 모양 결정

                // 1. 위쪽 메시지가 나와 같은 사람인가?
                bool isPrevSame = false;
                if (msgIndex < _messages.length - 1) {
                  isPrevSame =
                      _messages[msgIndex + 1].isSentByMe == message.isSentByMe;
                }

                // 2. 아래쪽 메시지가 나와 같은 사람인가?
                bool isNextSame = false;
                if (msgIndex > 0) {
                  isNextSame =
                      _messages[msgIndex - 1].isSentByMe == message.isSentByMe;
                }

                return _buildMessageBubble(
                    message, msgIndex, showTime, isPrevSame, isNextSame);
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

  Widget _buildMessageBubble(ChatMessage message, int index, bool showTime,
      bool isPrevSame, bool isNextSame) {
    final isMe = message.isSentByMe;
    final showSeen = isMe && message.status == MessageStatus.seen && index == 0;
    String formattedTime =
        "Today ${DateFormat('h:mm a').format(message.timestamp)}";

    // ⭐️ 말풍선 반경 계산 (4px = 뾰족함, 22px = 둥그러움)
    // 내가 보낸 거면: 오른쪽 위/아래가 변함
    // 상대가 보낸 거면: 왼쪽 위/아래가 변함
    BorderRadius bubbleRadius;

    if (isMe) {
      bubbleRadius = BorderRadius.only(
        topLeft: const Radius.circular(22),
        bottomLeft: const Radius.circular(22),
        topRight: isPrevSame
            ? const Radius.circular(4)
            : const Radius.circular(22), // 위쪽이 같으면 뾰족
        bottomRight: isNextSame
            ? const Radius.circular(4)
            : const Radius.circular(22), // 아래쪽이 같으면 뾰족
      );
    } else {
      bubbleRadius = BorderRadius.only(
        topRight: const Radius.circular(22),
        bottomRight: const Radius.circular(22),
        topLeft:
            isPrevSame ? const Radius.circular(4) : const Radius.circular(22),
        bottomLeft:
            isNextSame ? const Radius.circular(4) : const Radius.circular(22),
      );
    }

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
                crossAxisAlignment:
                    CrossAxisAlignment.end, // 아래쪽 정렬 (프로필 사진 위치 때문)
                children: [
                  if (!isMe) ...[
                    // ⭐️ 상대방 프로필은 그룹의 맨 마지막(가장 아래) 메시지에만 표시하거나, 항상 표시하되 투명하게 처리
                    // 여기서는 심플하게 '다음 메시지가 다른 사람이거나 없을 때'만 표시
                    if (!isNextSame)
                      CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage(widget.profilePicAsset))
                    else
                      const SizedBox(width: 28), // 프로필 공간 확보

                    const SizedBox(width: 8),
                  ],
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    // ⭐️ 말풍선 간격: 그룹 내부는 2, 그룹 간은 4
                    margin: EdgeInsets.only(top: isPrevSame ? 2 : 4, bottom: 2),
                    decoration: BoxDecoration(
                      // ⭐️ 보라색 적용 (0xFF7F3DFF)
                      color: isMe
                          ? const Color(0xFF7F3DFF)
                          : const Color(0xFFEFEFEF),
                      borderRadius: bubbleRadius, // 계산된 모양 적용
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
                      padding: EdgeInsets.only(left: 8, bottom: 12),
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
                    message.text == "Nice to meet you!"
                        ? "Seen"
                        : "Seen just now",
                    style:
                        const TextStyle(color: secondaryColor, fontSize: 12)),
              ),

            // ⭐️ 5초 타이머 & 최신 메시지 조건
            if (!isMe && index == 0 && _showReactHint)
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
                  color: Color(0xFF7F3DFF), shape: BoxShape.circle), // 보라색
              child: const Icon(Icons.search, color: Colors.white, size: 24),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Color(0xFF7F3DFF), shape: BoxShape.circle), // 보라색
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
                        color: Color(0xFF7F3DFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)), // 보라색 텍스트
              ),
            )
          else
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
