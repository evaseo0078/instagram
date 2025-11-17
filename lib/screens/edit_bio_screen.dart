// 📍 lib/screens/edit_bio_screen.dart (전체 코드)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/utils/colors.dart';

class EditBioScreen extends StatefulWidget {
  final String currentBio;
  const EditBioScreen({super.key, required this.currentBio});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  late TextEditingController _bioController;
  int _charCount = 0;
  final int _maxChars = 150;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
    _charCount = widget.currentBio.length;
    _bioController.addListener(() {
      setState(() {
        _charCount = _bioController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryColor), // "X" 버튼
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue), // "V" 버튼
            onPressed: () {
              Navigator.of(context).pop(_bioController.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bio',
                style: TextStyle(color: secondaryColor, fontSize: 12)),
            TextField(
              controller: _bioController,
              autofocus: true,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              inputFormatters: [
                LengthLimitingTextInputFormatter(_maxChars),
              ],
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$_charCount/$_maxChars',
                  style: const TextStyle(color: secondaryColor, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                style: TextStyle(color: secondaryColor, fontSize: 12),
                children: [
                  TextSpan(
                      text:
                          'Your bio is visible to everyone on and off Instagram. '),
                  TextSpan(
                    text: 'Learn more',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
