import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/connection_status_banner_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/message_input_widget.dart';
import '../../services/database_service.dart';

/// Chat Conversation Screen
/// Provides intuitive messaging interface optimized for Bluetooth communication
/// with connection status awareness and offline capabilities
class ChatConversation extends StatefulWidget {
  final String? conversationId;
  final String? deviceName;
  
  const ChatConversation({
    super.key,
    this.conversationId,
    this.deviceName,
  });

  @override
  State<ChatConversation> createState() => _ChatConversationState();
}

class _ChatConversationState extends State<ChatConversation> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _showScrollToBottom = false;
  bool _isConnected = true;
  bool _isReconnecting = false;
  int _unreadCount = 0;
  final int _pendingMessagesCount = 0;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// Load messages from Supabase
  Future<void> _loadMessages() async {
    final conversationId = widget.conversationId ?? 'default';
    try {
      final messages = await DatabaseService.getMessages(
        conversationId: conversationId,
      );
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;
      if (_showScrollToBottom == isAtBottom) {
        setState(() {
          _showScrollToBottom = !isAtBottom;
          if (isAtBottom) _unreadCount = 0;
        });
      }
    }
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

  void _retryConnection() {
    setState(() {
      _isReconnecting = true;
    });
    // Reconnect logic using Bluetooth service
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isReconnecting = false;
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final conversationId = widget.conversationId ?? 'default';
    
    setState(() {
      _messages.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "text": messageText,
        "timestamp": DateTime.now(),
        "isSent": true,
        "status": _isConnected ? "sending" : "pending",
        "senderName": "You",
      });
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    // Save message to Supabase
    DatabaseService.sendMessage(
      messageText,
      conversationId: conversationId,
    );

    if (_isConnected) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.last["status"] = "delivered";
          });
        }
      });
    }
  }

  void _retryMessage(String messageId) {
    setState(() {
      final messageIndex = _messages.indexWhere((m) => m["id"] == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex]["status"] = "sending";
      }
    });

    // Resend message logic
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final messageIndex = _messages.indexWhere(
            (m) => m["id"] == messageId,
          );
          if (messageIndex != -1) {
            _messages[messageIndex]["status"] = "delivered";
          }
        });
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${timestamp.month}/${timestamp.day}/${timestamp.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceName = widget.deviceName ?? 'Device';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: _isConnected
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'bluetooth',
                  color: theme.colorScheme.onPrimary,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isConnected ? "Connected" : "Disconnected",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _isConnected
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isConnected)
            ConnectionStatusBannerWidget(
              isReconnecting: _isReconnecting,
              onRetry: _retryConnection,
            ),
          if (_pendingMessagesCount > 0 && !_isConnected)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              color: theme.colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "$_pendingMessagesCount messages pending",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'chat_bubble_outline',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 64,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No messages yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Start a conversation by sending a message',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return MessageBubbleWidget(
                            message: message,
                            onRetry: () => _retryMessage(message["id"] as String),
                            formatTimestamp: _formatTimestamp,
                          );
                        },
                      ),
                if (_showScrollToBottom)
                  Positioned(
                    right: 4.w,
                    bottom: 2.h,
                    child: FloatingActionButton.small(
                      onPressed: _scrollToBottom,
                      backgroundColor: theme.colorScheme.primary,
                      child: Badge(
                        isLabelVisible: _unreadCount > 0,
                        label: Text(_unreadCount.toString()),
                        child: CustomIconWidget(
                          iconName: 'keyboard_arrow_down',
                          color: theme.colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          MessageInputWidget(
            controller: _messageController,
            isConnected: _isConnected,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
