import 'package:flutter/material.dart';
import 'ai_client.dart';
import 'chat_interface.dart';
import 'models.dart';

class ChatBotWidget extends StatefulWidget {
  final String apiKey;
  final Color primaryColor;
  final IconData chatIcon;
  final String initialMessage;
  final AIService aiService;
  final bool clearHistoryOnClose;
  final String headerTitle;
  final IconData headerIcon;

  const ChatBotWidget({
    required this.apiKey,
    this.primaryColor = Colors.blue,
    this.chatIcon = Icons.chat,
    this.initialMessage = 'How can I help you?',
    required this.aiService,
    this.clearHistoryOnClose = false,
    this.headerTitle = 'AI Chatbot',
    this.headerIcon = Icons.smart_toy,
  });

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showChatInterface() {
    // Add initial message only if the chat is empty
    if (_controller.isEmpty) {
      _controller.addMessage(
        ChatMessage(
          text: widget.initialMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatInterface(
        controller: _controller,
        apiKey: widget.apiKey,
        primaryColor: widget.primaryColor,
        initialMessage: widget.initialMessage,
        aiService: widget.aiService,
        headerTitle: widget.headerTitle,
        headerIcon: widget.headerIcon,
      ),
    ).whenComplete(() {
      if (widget.clearHistoryOnClose) {
        _controller.clearMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: widget.primaryColor,
            child: Icon(widget.chatIcon, color: Colors.white),
            onPressed: () => _showChatInterface(),
          ),
        ),
      ],
    );
  }
}