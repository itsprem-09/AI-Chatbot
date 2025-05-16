import 'package:flutter/material.dart';
import 'package:flutter_ai_chatbot/flutter_ai_chatbot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('AI Chat Demo')),
        body: const Center(child: Text('Main Content')),
        floatingActionButton: ChatBotWidget(
          apiKey: 'Your api-key is here',
          primaryColor: Colors.deepPurple,
          chatIcon: Icons.chat_sharp,
          initialMessage: 'Hello! How can I assist you today?',
          // aiService: AIService.openAI,
          aiService: AIService.gemini,
          // aiService: AIService.deepseek,
          clearHistoryOnClose: true,
          headerTitle: 'My Custom Assistant',
          headerIcon: Icons.psychology,
        ),
      ),
    );
  }
}