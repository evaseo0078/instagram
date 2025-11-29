import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

class AddPostScreen extends StatefulWidget {
  final File imageFile;

  const AddPostScreen({super.key, required this.imageFile});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ⭐️ [Share 버튼] - 바로 포스팅
  void _onSharePressed() {
    final caption = _captionController.text;
    print('🔍 AddPostScreen Share pressed, caption: "$caption"');
    print('📤 Popping AddPostScreen with caption');
    Navigator.of(context).pop(caption);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("New post",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          if (_isKeyboardVisible)
            TextButton(
              onPressed: () => _focusNode.unfocus(),
              child: const Text("OK",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: widget.imageFile.path.isNotEmpty
                          ? Image.file(widget.imageFile, fit: BoxFit.contain)
                          : Image.asset('assets/images/profiles/kid_go.png',
                              fit: BoxFit.contain),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _captionController,
                      focusNode: _focusNode,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Add a caption...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // 기타 옵션들 (UI 유지)
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildSmallButton(Icons.poll_outlined, "Poll"),
                        const SizedBox(width: 8),
                        _buildSmallButton(Icons.chat_bubble_outline, "Prompt"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  _buildListTile(
                      icon: Icons.person_outline, text: "Tag people"),
                  _buildListTile(
                      icon: Icons.location_on_outlined, text: "Add location"),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                        "People you share this content with can see the location you tag and view this content on the \nmap.",
                        style: TextStyle(
                            color: secondaryColor, fontSize: 11, height: 1.3)),
                  ),
                  Container(height: 12, color: const Color(0xFFF5F5F5)),
                  _buildListTile(
                      icon: Icons.visibility_outlined,
                      text: "Audience",
                      trailingText: "Everyone"),
                  _buildListTile(
                      icon: Icons.ios_share,
                      text: "Also share on...",
                      hasNewBadge: true,
                      trailingText: "Off"),
                  Container(height: 12, color: const Color(0xFFF5F5F5)),
                  _buildListTile(icon: Icons.more_horiz, text: "More options"),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Share 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
                color: Colors.white),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onSharePressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    elevation: 0),
                child: const Text("Share",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.black),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
      ]),
    );
  }

  Widget _buildListTile(
      {required IconData icon,
      required String text,
      String? trailingText,
      bool hasNewBadge = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, color: Colors.black, size: 26),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText,
                style: const TextStyle(color: secondaryColor, fontSize: 14)),
          if (hasNewBadge) ...[
            const SizedBox(width: 8),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text("New",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
          ],
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {},
    );
  }
}
