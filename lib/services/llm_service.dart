// 📍 lib/services/llm_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LlmService {
  // .env에서 API 키를 불러옵니다
  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // ⭐️ 텍스트 정제 함수 (이상한 기호 제거)
  static String _cleanResponse(String text) {
    return text
        .replaceAll('<s>', '') // 시작 태그 제거
        .replaceAll('</s>', '') // 종료 태그 제거
        .replaceAll('[/s]', '') // 이상한 종료 태그 제거
        .replaceAll('[OUT]', '') // 출력 태그 제거
        .replaceAll('[/OUT]', '') // 출력 종료 태그 제거
        .replaceAll(RegExp(r'<.*?>'), '') // 혹시 모를 다른 괄호 태그 제거
        .trim(); // 앞뒤 공백 제거
  }

  // 텍스트 질문 -> 텍스트 답변
  static Future<String> getChatResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // ⭐️ 모델을 조금 더 안정적인 Llama 3로 변경하는 것을 추천합니다 (선택사항)
          // 기존: 'mistralai/mistral-7b-instruct:free',
          'model': 'mistralai/mistral-7b-instruct:free',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawContent = data['choices'][0]['message']['content'];

        // ⭐️ 여기서 정제 함수를 통해 깨끗한 텍스트만 반환
        return _cleanResponse(rawContent);
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

  // 이미지 + 텍스트 질문 -> 텍스트 답변
  static Future<String> getVisionResponse(File imageFile, String prompt) async {
    try {
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final String mimeType =
          imageFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
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
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawContent = data['choices'][0]['message']['content'];

        // ⭐️ 여기도 정제 함수 적용
        return _cleanResponse(rawContent);
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
