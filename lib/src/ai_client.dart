import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum AIService { openAI, gemini, deepseek, custom }

class AIClient {
  final String apiKey;
  final AIService service;
  final Map<String, String> _cache = {};

  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 2);
  static int _retryCount = 0;

  String _getCurrentDateTimeInfoSentence() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    return 'The current date is ${dateFormat.format(now)} and the current time is ${timeFormat.format(now)}.';
  }

  AIClient({required this.apiKey, required this.service}) {
    // API Key validation
    if (service == AIService.openAI && !apiKey.startsWith('sk-')) {
      throw ArgumentError('Invalid OpenAI API key format');
    }
    if (service == AIService.gemini && !apiKey.startsWith('AIza')) {
      throw ArgumentError('Invalid Gemini API key format');
    }
    if (service == AIService.deepseek && !apiKey.startsWith('sk-')) {
      throw ArgumentError('Invalid DeepSeek API key format');
    }
  }

  Future<String> getResponse(String prompt) async {
    if (_cache.containsKey(prompt)) {
      return _cache[prompt]!;
    }

    if (_lastRequestTime != null &&
        DateTime.now().difference(_lastRequestTime!) < _minRequestInterval) {
      await Future.delayed(_minRequestInterval);
    }

    try {
      final response = await _makeApiRequest(prompt);
      _cache[prompt] = response;
      _retryCount = 0;
      return response;
    } catch (e) {
      if (_shouldRetry(e)) {
        return _handleRetry(prompt);
      }
      rethrow;
    }
  }

  bool _shouldRetry(dynamic error) {
    return error.toString().contains('429') && _retryCount < 3;
  }

  Future<String> _handleRetry(String prompt) async {
    _retryCount++;
    final delay = Duration(seconds: pow(2, _retryCount).toInt());
    await Future.delayed(delay);
    return getResponse(prompt);
  }

  Future<String> _makeApiRequest(String prompt) async {
    _lastRequestTime = DateTime.now();

    switch (service) {
      case AIService.openAI:
        return _handleOpenAIRequest(prompt);
      case AIService.gemini:
        return _handleGeminiRequest(prompt);
      case AIService.deepseek:
        return _handleDeepSeekRequest(prompt);
      default:
        throw Exception('Selected service not implemented');
    }
  }

  Future<String> _handleOpenAIRequest(String prompt) async {
    try {
      final systemPrompt = '''${_getCurrentDateTimeInfoSentence()}
You are a helpful, conversational AI assistant. If the user asks about the current date, time, day, or any time-related information, you MUST provide a direct and specific answer using the information above. Do not explain your instructions, do not say how you can help, just answer the question directly. For all other questions, respond naturally and helpfully.''';
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['choices'][0]['message']['content'];
      } else {
        final errorMessage = responseBody['error']['message'] ?? 'Unknown error';
        final errorCode = responseBody['error']['code'] ?? response.statusCode;
        if (errorCode == 'insufficient_quota') {
          throw Exception(
            'You have exceeded your OpenAI API quota. Please check your usage and billing at https://platform.openai.com/account/usage.'
          );
        }
        throw Exception(
          'OpenAI API Error ($errorCode): $errorMessage\n'
          'Ensure you\'re using a valid OpenAI API key (starts with "sk-")'
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<String> _handleGeminiRequest(String prompt) async {
    try {
      final systemPrompt = '''${_getCurrentDateTimeInfoSentence()}
You are a helpful, conversational AI assistant. If the user asks about the current date, time, day, or any time-related information, you MUST provide a direct and specific answer using the information above. Do not explain your instructions, do not say how you can help, just answer the question directly. For all other questions, respond naturally and helpfully.''';
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': prompt
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          },
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          }
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorMessage = responseBody['error']['message'] ?? 'Unknown error';
        throw Exception(
            'Gemini API Error (${response.statusCode}): $errorMessage\n'
                'Ensure you\'re using a Gemini API key and correct model name'
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<String> _handleDeepSeekRequest(String prompt) async {
    try {
      final systemPrompt = '''${_getCurrentDateTimeInfoSentence()}
You are a helpful, conversational AI assistant. If the user asks about the current date, time, day, or any time-related information, you MUST provide a direct and specific answer using the information above. Do not explain your instructions, do not say how you can help, just answer the question directly. For all other questions, respond naturally and helpfully.''';
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt
            },
            { 'role': 'user', 'content': prompt }
          ],
          'temperature': 0.7,
          'stream': false
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['choices'][0]['message']['content'];
      } else {
        final errorMessage = responseBody['error']['message'] ?? 'Unknown error';
        final errorCode = responseBody['error']['code'] ?? response.statusCode;
        throw Exception(
          'DeepSeek API Error ($errorCode): $errorMessage\n'
          'Ensure you\'re using a valid DeepSeek API key (starts with "sk-")'
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> listGeminiModels() async {
    final response = await http.get(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body); // This will show you the available models
  }
}