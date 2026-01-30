import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/conversation_card_widget.dart';

/// Messages View - Displays all chat conversations
class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    _conversations.addAll([
      {
        "id": "conv_001",
        "deviceId": "device_004",
        "deviceName": "Emma's Pixel 7",
        "nickname": "Emma",
        "lastMessage": "Great! Let me know if you need anything else",
        "lastMessageTime": DateTime.now().subtract(const Duration(minutes: 41)),
        "unreadCount": 2,
        "isOnline": true,
        "deviceType": "phone",
      },
      {
        "id": "conv_002",
        "deviceId": "device_002",
        "deviceName": "Michael's MacBook Pro",
        "nickname": "Work Laptop",
        "lastMessage": "Thanks for the update!",
        "lastMessageTime": DateTime.now().subtract(const Duration(hours: 2)),
        "unreadCount": 0,
        "isOnline": false,
        "deviceType": "computer",
      },
      {
        "id": "conv_003",
        "deviceId": "device_001",
        "deviceName": "Sarah's iPhone 13",
        "nickname": null,
        "lastMessage": "See you tomorrow!",
        "lastMessageTime": DateTime.now().subtract(const Duration(hours: 5)),
        "unreadCount": 0,
        "isOnline": false,
        "deviceType": "phone",
      },
    ]);
  }

  void _openConversation(Map<String, dynamic> conversation) {
    Navigator.pushNamed(
      context,
      AppRoutes.chatConversation,
      arguments: conversation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Messages',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: CustomIconWidget(
                        iconName: 'search',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      tooltip: 'Search',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _conversations.isEmpty
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
                          'No conversations yet',
                          style: theme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Connect to a device to start chatting',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return ConversationCardWidget(
                        conversation: conversation,
                        onTap: () => _openConversation(conversation),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
