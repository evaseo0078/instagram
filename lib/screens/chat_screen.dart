// 📍 lib/screens/chat_screen.dart (신규 파일)

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/services/llm_service.dart'; // ⭐️ 1단계에서 만든 파일
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/loading_utils.dart'; // ⭐️ 로딩 유틸 사용

// 1. 채팅 메시지를 위한 데이터 모델
class ChatMessage {
  final String text;
  final bool isSentByMe;
  final File? imageFile; // ⭐️ 이미지를 위한 필드

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    this.imageFile,
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
  final List<ChatMessage> _messages = []; // ⭐️ 메시지 목록
  final ImagePicker _picker = ImagePicker();
  bool _isLlmResponding = false;
  File? _pickedImagePreview; // ⭐️ 영상 1:15 하단 프리뷰용

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ⭐️ 텍스트 메시지 전송 (영상 0:40)
  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    // 1. 내 메시지 추가
    setState(() {
      _messages.add(ChatMessage(text: text, isSentByMe: true));
      _isLlmResponding = true;
    });
    _messageController.clear();

    // 2. LLM 응답 요청
    final String llmResponse = await LlmService.getChatResponse(text);

    // 3. LLM 응답 추가
    setState(() {
      _messages.add(ChatMessage(text: llmResponse, isSentByMe: false));
      _isLlmResponding = false; // "Read" 인디케이터 대신 로딩 중지 [cite: 38]
    });
  }

  // ⭐️ 이미지 선택 (영상 1:12) [cite: 38]
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        // ⭐️ 영상 1:15 처럼 하단에 프리뷰
        _pickedImagePreview = File(image.path);
      });
    }
  }

  // ⭐️ 이미지 + 텍스트 전송 (영상 1:16) [cite: 38]
  Future<void> _sendImageAndMessage() async {
    if (_pickedImagePreview == null) return;

    final String text = _messageController.text;
    final File imageToSend = _pickedImagePreview!;

    // 1. 내 메시지(이미지+텍스트) 추가
    setState(() {
      _messages.add(ChatMessage(
        text: text, // 캡션
        isSentByMe: true,
        imageFile: imageToSend, // ⭐️ 이미지 첨부
      ));
      _isLlmResponding = true;
      _pickedImagePreview = null; // ⭐️ 프리뷰 제거
      _messageController.clear();
    });

    // 2. LLM (Vision) 응답 요청
    // (영상에서는 프롬프트를 따로 안보내지만, 여기선 캡션을 프롬프트로 활용)
    final String prompt =
        text.isEmpty ? "What do you see in this image?" : text;
    final String llmResponse =
        await LlmService.getVisionResponse(imageToSend, prompt);

    // 3. LLM 응답 추가
    setState(() {
      _messages.add(ChatMessage(text: llmResponse, isSentByMe: false));
      _isLlmResponding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.profilePicAsset),
              onBackgroundImageError: (e, s) {},
              child: !widget.profilePicAsset.contains('assets/')
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(widget.username,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.phone, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.video_camera, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ⭐️ 1. 채팅 목록
          Expanded(
            child: ListView.builder(
              reverse: true, // ⭐️ 채팅은 항상 아래부터 쌓입니다
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // ⭐️ 최신 메시지가 아래에 오도록 역순 접근
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // ⭐️ LLM 응답 대기 중 "Typing..." (영상 0:55)
          if (_isLlmResponding)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(width: 8),
                  Text('Typing...', style: TextStyle(color: secondaryColor)),
                ],
              ),
            ),
          // ⭐️ 2. 하단 입력창
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ⭐️ 메시지 말풍선 위젯
  Widget _buildMessageBubble(ChatMessage message) {
    final bool isMe = message.isSentByMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[850],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐️ 보낸 이미지가 있다면 (영상 1:16)
              if (message.imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    message.imageFile!,
                    width: 200, // 임시 크기
                    fit: BoxFit.cover,
                  ),
                ),
              // ⭐️ 텍스트 (캡션 또는 그냥 메시지)
              if (message.text.isNotEmpty)
                Padding(
                  padding:
                      EdgeInsets.only(top: message.imageFile != null ? 8.0 : 0),
                  child: Text(
                    message.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          )),
    );
  }

  // ⭐️ 하단 메시지 입력창 위젯 (영상 0:40, 1:15)
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          // ⭐️ 영상 1:15 이미지 프리뷰 [cite: 38]
          if (_pickedImagePreview != null)
            Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 8.0),
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_pickedImagePreview!),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImagePreview = null),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
          // ⭐️ 입력창
          Row(
            children: [
              // ⭐️ 카메라 아이콘 (영상 1:12)
              IconButton(
                icon: const Icon(CupertinoIcons.camera_fill,
                    color: Colors.blue, size: 30),
                onPressed: _pickImage,
              ),
              const SizedBox(width: 8),
              // ⭐️ 텍스트 필드
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: primaryColor),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: const TextStyle(color: secondaryColor),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    suffixIcon: _pickedImagePreview == null
                        ? null // ⭐️ 이미지가 없을 땐 Send 버튼 없음
                        : IconButton(
                            // ⭐️ 이미지가 있으면 텍스트 Send 버튼 (영상 1:16)
                            icon: const Text('Send',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold)),
                            onPressed: _sendImageAndMessage,
                          ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  // ⭐️ 텍스트만 보낼 때 (영상 0:45)
                  onSubmitted:
                      _pickedImagePreview == null ? _sendMessage : null,
                ),
              ),
              // ⭐️ 텍스트만 있을 때 Send 버튼
              if (_pickedImagePreview == null)
                TextButton(
                  child: const Text('Send',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
