import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import 'models.dart';
import 'ai_client.dart';

class ChatInterface extends StatefulWidget {
  final ChatController controller;
  final String apiKey;
  final Color primaryColor;
  final String initialMessage;
  final AIService aiService;
  final String headerTitle;
  final IconData headerIcon;

  const ChatInterface({
    required this.controller,
    required this.apiKey,
    required this.primaryColor,
    required this.initialMessage,
    required this.aiService,
    this.headerTitle = 'AI Chatbot',
    this.headerIcon = Icons.smart_toy,
  });

  @override
  _ChatInterfaceState createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showTypingIndicator = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              _buildHeader(context),
              if (_isLoading)
                LinearProgressIndicator(
                  color: widget.primaryColor,
                  minHeight: 2,
                  backgroundColor: widget.primaryColor.withOpacity(0.1),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.03,
                          child: CustomPaint(
                            painter: PatternPainter(color: widget.primaryColor),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.primaryColor.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Chat messages
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: StreamBuilder<List<ChatMessage>>(
                          stream: widget.controller.messagesStream,
                          initialData: widget.controller.messages,
                          builder: (context, snapshot) {
                            return ListView.builder(
                              controller: _scrollController,
                              reverse: false,
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              itemCount: (snapshot.data?.length ?? 0) + (_showTypingIndicator ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == snapshot.data!.length && _showTypingIndicator) {
                                  return _buildTypingIndicator();
                                }
                                final message = snapshot.data![index];
                                return _buildMessageItem(message);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildInputField(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ChatBubble(
                message: message,
                primaryColor: widget.primaryColor,
                assistantIcon: widget.headerIcon,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(0.5 + (0.5 * value)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'chat_icon',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(widget.headerIcon, color: widget.primaryColor, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.headerTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.primaryColor.withOpacity(0.7),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(Icons.close, color: widget.primaryColor, size: 20),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  if (_textController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey.shade400),
                      onPressed: () {
                        // TODO: Implement emoji picker
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isLoading ? Colors.grey : widget.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: (_isLoading ? Colors.grey : widget.primaryColor).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isLoading ? null : _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showTypingIndicator = true;
    });

    final userMessage = ChatMessage(
      text: _textController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    widget.controller.addMessage(userMessage);
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await AIClient(
        apiKey: widget.apiKey,
        service: widget.aiService,
      ).getResponse(userMessage.text);

      setState(() => _showTypingIndicator = false);

      widget.controller.addMessage(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() => _showTypingIndicator = false);
      widget.controller.addMessage(
        ChatMessage(
          text: 'Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}',
          isUser: false,
          isError: true,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }
}

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    for (var i = 0; i < size.width; i += spacing as int) {
      for (var j = 0; j < size.height; j += spacing as int) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
