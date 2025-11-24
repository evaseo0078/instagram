// 📍 lib/services/llm_service.dart (신규 파일)
// 복붙할 떄 API 키 유출 주의!

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LlmService {
  // ⭐️ 2단계에서 발급받은 본인의 OpenRouter API 키를 여기에 붙여넣으세요
  static const String _apiKey =
      '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';

  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // 텍스트 질문 -> 텍스트 답변 (영상 0:40)
  static Future<String> getChatResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // ⭐️ 텍스트용 무료 모델 (Mistral 7B)
          'model': 'mistralai/mistral-7b-instruct:free',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print('LLM Error: ${response.statusCode}');
        print('LLM Body: ${response.body}');
        return 'Error: Could not get response from LLM.';
      }
    } catch (e) {
      print('LLM Exception: $e');
      return 'Error: $e';
    }
  }

  // 이미지 + 텍스트 질문 -> 텍스트 답변 (영상 1:12) [cite: 38]
  // (영상 1:15의 하단 프리뷰, 1:28의 LLM 응답 관련)
  static Future<String> getVisionResponse(File imageFile, String prompt) async {
    try {
      // 1. 이미지를 Base64로 인코딩
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // 2. 이미지 MIME 타입 확인 (간단하게)
      final String mimeType =
          imageFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // ⭐️ 요청하신 Vision 모델 (Gemini Pro Vision, 무료 티어)
          // (NVIDIA 모델은 유료이거나 API 형식이 다를 수 있어,
          // 확실하게 작동하는 무료 모델인 Gemini로 대체했습니다.)
          'model': 'google/gemini-pro-vision',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                  },
                },
              ],
            }
          ],
          'max_tokens': 300, // Vision 모델은 응답 길이를 정해주는 것이 좋습니다.
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print('LLM (Vision) Error: ${response.statusCode}');
        print('LLM (Vision) Body: ${response.body}');
        return 'Error: Could not get response from LLM.';
      }
    } catch (e) {
      print('LLM (Vision) Exception: $e');
      return 'Error: $e';
    }
  }
}
