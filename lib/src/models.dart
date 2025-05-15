import 'dart:async';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatController {
  final _messages = <ChatMessage>[];
  late final StreamController<List<ChatMessage>> _streamController;

  ChatController() {
    _streamController = StreamController<List<ChatMessage>>.broadcast();
  }

  Stream<List<ChatMessage>> get messagesStream => _streamController.stream;

  bool get isEmpty => _messages.isEmpty;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void addMessage(ChatMessage message) {
    if (!_streamController.isClosed) {
      _messages.add(message);
      _streamController.add(List.from(_messages));
    }
  }

  void clearMessages() {
    if (!_streamController.isClosed) {
      _messages.clear();
      _streamController.add(List.from(_messages));
    }
  }

  void dispose() {
    if (!_streamController.isClosed) {
      _streamController.close();
    }
  }
}