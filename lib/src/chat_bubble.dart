import 'package:flutter/material.dart';
import 'models.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Color primaryColor;
  final IconData assistantIcon;

  const ChatBubble({
    required this.message,
    required this.primaryColor,
    this.assistantIcon = Icons.smart_toy,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isUser ? 64 : 0,
          right: message.isUser ? 0 : 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? primaryColor
              : message.isError
                  ? Colors.red.shade50
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: (message.isUser ? primaryColor : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: message.isUser
              ? null
              : Border.all(
                  color: message.isError
                      ? Colors.red.shade200
                      : Colors.grey.shade200,
                  width: 1,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        assistantIcon,
                        size: 18,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Assistant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor.withOpacity(0.8),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: message.isUser
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.8),
                        ],
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser
                        ? Colors.white
                        : message.isError
                            ? Colors.red.shade900
                            : Colors.black87,
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: message.isUser
                        ? Colors.white.withOpacity(0.7)
                        : message.isError
                            ? Colors.red.shade900.withOpacity(0.7)
                            : Colors.black54,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
                if (message.isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}