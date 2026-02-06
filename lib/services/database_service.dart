import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/env.dart';

/// Database service for BlueChat
/// Handles all CRUD operations for conversations and messages
///
/// NOTE: Uses device-based identification instead of user authentication.
/// Users are identified by their device ID (stored locally).
class DatabaseService {
  final SupabaseClient _client;
  final String _deviceId;
  final String _username;

  DatabaseService({
    required String deviceId,
    required String username,
  })  : _client = Supabase.instance.client,
        _deviceId = deviceId,
        _username = username;

  // ==================== Profiles ====================

  /// Create or update user profile
  Future<dynamic> upsertProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final response = await _client.from(SupabaseTables.profiles).upsert({
      'id': _deviceId,
      'device_id': _deviceId,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).select();
    return response;
  }

  /// Get user profile by device ID
  Future<dynamic> getProfile({String? deviceId}) async {
    final id = deviceId ?? _deviceId;
    final response = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  /// Update online status
  Future<dynamic> updateOnlineStatus({required bool isOnline}) async {
    final response = await _client
        .from(SupabaseTables.profiles)
        .update({
          'is_online': isOnline,
          'last_seen': DateTime.now().toIso8601String(),
        })
        .eq('id', _deviceId)
        .select();
    return response;
  }

  /// Get all online users
  Future<List<dynamic>> getOnlineUsers() async {
    final response = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('is_online', true);
    return response;
  }

  // ==================== Conversations ====================

  /// Create a new conversation
  Future<dynamic> createConversation({
    required String name,
    String? avatarUrl,
    bool isGroup = false,
  }) async {
    final response = await _client.from(SupabaseTables.conversations).insert({
      'name': name,
      'avatar_url': avatarUrl,
      'is_group': isGroup,
      'created_by': _deviceId,
      'created_at': DateTime.now().toIso8601String(),
    }).select();

    // Add creator as participant
    if (response.isNotEmpty) {
      await addParticipant(
        conversationId: response[0]['id'],
        deviceId: _deviceId,
        isAdmin: true,
      );
    }

    return response;
  }

  /// Get conversation by ID
  Future<dynamic> getConversation({required String conversationId}) async {
    final response = await _client
        .from(SupabaseTables.conversations)
        .select()
        .eq('id', conversationId)
        .single();
    return response;
  }

  /// Get all conversations for a user
  Future<List<dynamic>> getUserConversations() async {
    final response = await _client
        .from(SupabaseTables.chatParticipants)
        .select('conversation_id, conversations(*)')
        .eq('device_id', _deviceId)
        .order('created_at', ascending: false);
    return response;
  }

  /// Update conversation details
  Future<dynamic> updateConversation({
    required String conversationId,
    String? name,
    String? avatarUrl,
  }) async {
    final Map<String, dynamic> updates = {
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final response = await _client
        .from(SupabaseTables.conversations)
        .update(updates)
        .eq('id', conversationId)
        .select();
    return response;
  }

  /// Delete conversation
  Future<void> deleteConversation({required String conversationId}) async {
    await _client
        .from(SupabaseTables.conversations)
        .delete()
        .eq('id', conversationId);
  }

  /// Add participant to conversation
  Future<dynamic> addParticipant({
    required String conversationId,
    String? deviceId,
    bool isAdmin = false,
  }) async {
    final id = deviceId ?? _deviceId;
    final response = await _client.from(SupabaseTables.chatParticipants).insert({
      'conversation_id': conversationId,
      'device_id': id,
      'joined_at': DateTime.now().toIso8601String(),
      'is_admin': isAdmin,
    }).select();
    return response;
  }

  /// Remove participant from conversation
  Future<void> removeParticipant({
    required String conversationId,
    String? deviceId,
  }) async {
    final id = deviceId ?? _deviceId;
    await _client.from(SupabaseTables.chatParticipants).delete().match({
      'conversation_id': conversationId,
      'device_id': id,
    });
  }

  /// Get conversation participants
  Future<List<dynamic>> getParticipants({required String conversationId}) async {
    final response = await _client
        .from(SupabaseTables.chatParticipants)
        .select()
        .eq('conversation_id', conversationId);
    return response;
  }

  // ==================== Messages ====================

  /// Send a new message
  Future<dynamic> sendMessage({
    required String conversationId,
    required String content,
    String? messageType,
    String? attachmentUrl,
  }) async {
    final response = await _client.from(SupabaseTables.messages).insert({
      'conversation_id': conversationId,
      'sender_device_id': _deviceId,
      'sender_name': _username,
      'content': content,
      'message_type': messageType ?? 'text',
      'attachment_url': attachmentUrl,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
    }).select();
    return response;
  }

  /// Get messages for a conversation
  Future<List<dynamic>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client
        .from(SupabaseTables.messages)
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .limit(limit)
        .range(offset, offset + limit - 1);
    return response;
  }

  /// Get unread message count for a conversation
  Future<int> getUnreadCount({required String conversationId}) async {
    final response = await _client
        .from(SupabaseTables.messages)
        .select()
        .eq('conversation_id', conversationId)
        .eq('is_read', false)
        .neq('sender_device_id', _deviceId);
    return response.length;
  }

  /// Mark message as read
  Future<void> markAsRead({required String messageId}) async {
    await _client
        .from(SupabaseTables.messages)
        .update({'is_read': true})
        .eq('id', messageId);
  }

  /// Mark all messages in conversation as read
  Future<void> markConversationAsRead({required String conversationId}) async {
    await _client
        .from(SupabaseTables.messages)
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_device_id', _deviceId)
        .eq('is_read', false);
  }

  /// Delete a message
  Future<void> deleteMessage({required String messageId}) async {
    await _client
        .from(SupabaseTables.messages)
        .delete()
        .eq('id', messageId);
  }

  /// Update message content
  Future<dynamic> updateMessage({
    required String messageId,
    required String content,
  }) async {
    final response = await _client
        .from(SupabaseTables.messages)
        .update({
          'content': content,
          'is_edited': true,
        })
        .eq('id', messageId)
        .select();
    return response;
  }

  // ==================== Search ====================

  /// Search messages by content
  Future<List<dynamic>> searchMessages({
    required String conversationId,
    required String query,
  }) async {
    final response = await _client
        .from(SupabaseTables.messages)
        .select()
        .eq('conversation_id', conversationId)
        .ilike('content', '%$query%')
        .order('created_at', ascending: false);
    return response;
  }

  /// Search users by username
  Future<List<dynamic>> searchUsers({required String query}) async {
    final response = await _client
        .from(SupabaseTables.profiles)
        .select()
        .ilike('username', '%$query%')
        .limit(20);
    return response;
  }
}
