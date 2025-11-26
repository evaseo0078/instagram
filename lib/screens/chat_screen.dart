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
import 'package:flutter_svg/flutter_svg.dart';

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
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _isLlmTyping = false;
  bool _showReactHint = false;

  final Color _purpleColor = const Color(0xFF7F3DFF);

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
    setState(() => _showReactHint = false);

    if (widget.username.contains("Ran")) {
      for (var msg in _messages) {
        if (msg.status == MessageStatus.seen) {
          msg.status = MessageStatus.sent;
        }
      }
    }

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

  // ⭐️ 수정됨: 시스템 갤러리(_picker)를 호출하지 않고 바로 커스텀 시트를 엽니다.
  void _openCustomGallery() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomGallerySheet(onSendImage: _sendImageMessage),
    );
  }

  // ⭐️ 이미지 메시지 전송
  // (assets 경로를 받아서 처리하도록 수정됨)
  void _sendImageMessage(String imagePath) {
    Navigator.pop(context);

    final newMessage = ChatMessage(
      text: "",
      isSentByMe: true,
      status: MessageStatus.sending,
      animate: true,
      timestamp: DateTime.now(),
      // File 객체에 경로를 담지만, 실제로는 assets 경로임 (UI에서 구분 처리)
      imageFile: File(imagePath),
    );

    setState(() {
      _messages.insert(0, newMessage);
      _showReactHint = false;
    });

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLlmTyping = true;
        });
        _getLlmResponse("I sent you a photo.");
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
          _showReactHint = true;
        });

        Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showReactHint = false);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLlmTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLlmTyping && index == 0) {
                  return _buildTypingIndicator();
                }

                final msgIndex = _isLlmTyping ? index - 1 : index;
                final message = _messages[msgIndex];

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

                bool isPrevSame = false;
                if (msgIndex < _messages.length - 1) {
                  isPrevSame = _messages[msgIndex + 1].isSentByMe ==
                          message.isSentByMe &&
                      message.timestamp
                              .difference(_messages[msgIndex + 1].timestamp)
                              .inMinutes <
                          1;
                }

                bool isNextSame = false;
                if (msgIndex > 0) {
                  isNextSame = _messages[msgIndex - 1].isSentByMe ==
                          message.isSentByMe &&
                      _messages[msgIndex - 1]
                              .timestamp
                              .difference(message.timestamp)
                              .inMinutes <
                          1;
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
    final isImage = message.imageFile != null;

    final showSeen =
        isMe && !isImage && message.status == MessageStatus.seen && index == 0;
    String formattedTime =
        "Today ${DateFormat('h:mm a').format(message.timestamp)}";

    BorderRadius bubbleRadius;
    if (isMe) {
      bubbleRadius = BorderRadius.only(
        topLeft: const Radius.circular(22),
        bottomLeft: const Radius.circular(22),
        topRight:
            isPrevSame ? const Radius.circular(4) : const Radius.circular(22),
        bottomRight:
            isNextSame ? const Radius.circular(4) : const Radius.circular(22),
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
            // 애니메이션
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 400),
              tween: Tween<Offset>(
                  begin: message.animate
                      ? (isImage ? const Offset(0, 1) : const Offset(0.5, 0))
                      : Offset.zero,
                  end: Offset.zero),
              curve: Curves.easeOutCubic,
              builder: (context, Offset offset, child) {
                return Transform.translate(
                  offset: isImage
                      ? Offset(0, offset.dy * 100)
                      : Offset(offset.dx * 50, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isMe) ...[
                    if (!isNextSame)
                      CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage(widget.profilePicAsset))
                    else
                      const SizedBox(width: 28),
                    const SizedBox(width: 8),
                  ],

                  // ⭐️ 이미지 메시지
                  if (isImage) ...[
                    if (isMe)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey[300], shape: BoxShape.circle),
                          child: const Icon(CupertinoIcons.paperplane_fill,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      // ⭐️ assets 경로 처리
                      child: message.imageFile!.path.startsWith('assets/')
                          ? Image.asset(message.imageFile!.path,
                              width: 220, fit: BoxFit.cover)
                          : Image.file(message.imageFile!,
                              width: 220, fit: BoxFit.cover),
                    ),
                  ]

                  // ⭐️ 텍스트 메시지
                  else ...[
                    // 말풍선
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      margin:
                          EdgeInsets.only(top: isPrevSame ? 2 : 4, bottom: 2),
                      decoration: BoxDecoration(
                        color: isMe ? _purpleColor : const Color(0xFFEFEFEF),
                        borderRadius: bubbleRadius,
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 16),
                      ),
                    ),

                    // ⭐️ 수정됨: 비행기가 말풍선 오른쪽(right)에 뜸
                    if (isMe && message.status == MessageStatus.sending)
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 4), // 텍스트 오른쪽
                        child: Icon(CupertinoIcons.paperplane,
                            size: 16, color: secondaryColor),
                      ),
                  ],
                ],
              ),
            ),

            if (showSeen ||
                (isMe && !isImage && message.text == "Nice to meet you!"))
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 8),
                child: Text(
                    message.text == "Nice to meet you!"
                        ? "Seen"
                        : "Seen just now",
                    style:
                        const TextStyle(color: secondaryColor, fontSize: 12)),
              ),

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
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            if (_isTyping)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.search, color: _purpleColor, size: 22),
              )
            else
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.all(6),
                decoration:
                    BoxDecoration(color: _purpleColor, shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.camera_fill,
                    color: Colors.white, size: 20),
              ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 16),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            if (!_isTyping) ...[
              const Icon(CupertinoIcons.mic_fill,
                  color: Colors.black87, size: 24),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _openCustomGallery, // ⭐️ 커스텀 갤러리 바로 열기
                child: SvgPicture.asset(
                  'assets/icons/Picture.svg',
                  width: 24,
                  height: 24,
                  colorFilter:
                      const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(
                'assets/icons/smile_square.svg',
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              const Icon(CupertinoIcons.plus_circle,
                  color: Colors.black87, size: 26),
              const SizedBox(width: 8),
            ] else ...[
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _purpleColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(CupertinoIcons.paperplane_fill,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ⭐️ 커스텀 갤러리 시트 (문자열 경로 전달)
class CustomGallerySheet extends StatefulWidget {
  final Function(String) onSendImage;
  const CustomGallerySheet({super.key, required this.onSendImage});

  @override
  State<CustomGallerySheet> createState() => _CustomGallerySheetState();
}

class _CustomGallerySheetState extends State<CustomGallerySheet>
    with SingleTickerProviderStateMixin {
  final List<String> _dummyImages = [
    'assets/images/posts/kid_go/post13_1.jpg',
    'assets/images/posts/ran/post13_1.jpg',
    'assets/images/posts/kid_go/post13_2.jpg',
    'assets/images/profiles/kid_go.png',
    'assets/images/profiles/ran.png',
    'assets/images/profiles/conan.png',
  ];

  int? _selectedIndex;
  late AnimationController _tooltipController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tooltipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation =
        CurvedAnimation(parent: _tooltipController, curve: Curves.elasticOut);
  }

  void _selectImage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tooltipController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Recents",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _dummyImages.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => _selectImage(index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(_dummyImages[index], fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7F3DFF)
                                : Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? const Text("1",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),

                      // ⭐️ 수정됨: 툴팁 위치 및 꼬리 방향
                      if (isSelected)
                        Positioned(
                          bottom: 10, right: 10, // 오른쪽 아래에 뜸
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 4)
                                    ],
                                  ),
                                  child: const Text("Tap to preview and edit",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: CustomPaint(
                                    painter: TooltipTrianglePainter(), // 아래 꼬리
                                    size: const Size(10, 6),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_selectedIndex != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(_dummyImages[_selectedIndex!],
                        width: 40, height: 40, fit: BoxFit.cover),
                  ),
                  GestureDetector(
                    onTap: () =>
                        widget.onSendImage(_dummyImages[_selectedIndex!]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F3DFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(CupertinoIcons.paperplane_fill,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ⭐️ 툴팁 꼬리 (아래쪽 역삼각형)
class TooltipTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawShadow(path, Colors.black26, 2.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
