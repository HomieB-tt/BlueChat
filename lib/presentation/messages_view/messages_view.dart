import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/conversation_card_widget.dart';
import '../../services/database_service.dart';

/// Messages View - Displays all chat conversations
/// Loads data from Supabase for real device conversations
class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  /// Load conversations from Supabase
  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    
    try {
      final conversations = await DatabaseService.getConversations();
      if (mounted) {
        setState(() {
          _conversations.clear();
          _conversations.addAll(conversations);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                      onPressed: _loadConversations,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _conversations.isEmpty
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
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.separated(
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
          ),
        ],
      ),
    );
  }
}
