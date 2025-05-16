# 🤖 ai_chatbot

![Pub Version](https://img.shields.io/pub/v/flutter_ai_chatbot)
![Issues](https://img.shields.io/github/issues/itsprem-09/AI-Chatbot)

A powerful Flutter package that enables you to implement a real-time AI chatbot with minimal effort. Supports multiple AI services including OpenAI, Gemini, and DeepSeek.

## ✨ Features

* 🤖 Easy integration of AI chatbots into any Flutter application
* 🔄 Support for multiple AI services:
  * OpenAI GPT
  * Google Gemini
  * DeepSeek AI
* 🎨 Highly customizable UI:
  * Custom colors
  * Custom icons
  * Custom header title
  * Custom initial message
* 📝 Chat history management
* ⚡ Real-time responses
* 🔒 Secure API key handling
* 🚀 Built-in error handling and retry mechanisms
* 💾 Response caching for better performance

## 🛠 Getting Started

### Prerequisites

* ✅ Flutter SDK ≥ 3.0.0
* ✅ Dart ≥ 2.18.0
* ✅ Valid API key from one of the supported services:
  * OpenAI API key (starts with 'sk-')
  * Gemini API key (starts with 'AIza')
  * DeepSeek API key (starts with 'sk-')

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  ai_chatbot: ^latest_version
```

Then run:

```bash
flutter pub get
```

## 📱 Usage

### Basic Implementation

```dart
import 'package:ai_chatbot/flutter_ai_chatbot.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AI Chat Demo')),
        body: const Center(child: Text('Main Content')),
        floatingActionButton: ChatBotWidget(
          apiKey: 'YOUR_API_KEY',
          aiService: AIService.gemini,
          primaryColor: Colors.deepPurple,
          chatIcon: Icons.chat_sharp,
          initialMessage: 'Hello! How can I assist you today?',
          clearHistoryOnClose: true,
          headerTitle: 'My Custom Assistant',
          headerIcon: Icons.psychology,
        ),
      ),
    );
  }
}
```

### Customization Options

The `ChatBotWidget` supports various customization options:

```dart
final chatBot = ChatBotWidget(
  // Required parameters
  apiKey: 'YOUR_API_KEY',
  aiService: AIService.gemini,
  
  // Optional customization
  primaryColor: Colors.deepPurple,    // Custom theme color
  chatIcon: Icons.chat_sharp,         // Custom chat icon
  initialMessage: 'Hello!',           // Custom initial message
  clearHistoryOnClose: true,          // Clear chat history on close
  headerTitle: 'My Assistant',        // Custom header title
  headerIcon: Icons.psychology,       // Custom header icon
);
```

## 🔧 Advanced Features

### Error Handling

The package includes built-in error handling for:
* Invalid API keys
* Network errors
* Rate limiting
* Service-specific errors

### Response Caching

Responses are cached to improve performance and reduce API calls for repeated queries.

### Rate Limiting

Built-in rate limiting to prevent API quota exhaustion and ensure smooth operation.

## 📁 Project Structure

```text
lib/
├── ai_chatbot.dart
src/
├── ai_client.dart
├── chat_bubble.dart
├── chat_interface.dart
├── chatbot.dart
├── models.dart
example/
├── main.dart
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📬 Support

For issues and feature requests, please create an issue in the GitHub repository.

---

Made with ❤️ by [Prem Jani]
