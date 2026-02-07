import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/env.dart';

/// Database service for BlueChat
/// Handles all CRUD operations for conversations and messages
///
/// NOTE: Uses device-based identification instead of user authentication.
/// Users are identified by their device ID (stored locally).
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Initialize with device ID and username
  void initialize({required String deviceId, required String username}) {
    // TODO: Store device ID and username in storage
  }

  // ==================== Profiles ====================

  /// Create or update user profile
  static Future<dynamic> upsertProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final deviceId = await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.profiles)
        .upsert({
          'id': deviceId,
          'device_id': deviceId,
          'username': username,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select();
    return response;
  }

  /// Get user profile by device ID
  static Future<dynamic> getProfile({String? deviceId}) async {
    final id = deviceId ?? await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  /// Update online status
  static Future<dynamic> updateOnlineStatus({required bool isOnline}) async {
    final deviceId = await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.profiles)
        .update({
          'is_online': isOnline,
          'last_seen': DateTime.now().toIso8601String(),
        })
        .eq('id', deviceId)
        .select();
    return response;
  }

  /// Get all online users
  static Future<List<dynamic>> getOnlineUsers() async {
    final response = await Supabase.instance.client
        .from(SupabaseTables.profiles)
        .select()
        .eq('is_online', true);
    return response;
  }

  // ==================== Conversations ====================

  /// Create a new conversation
  static Future<dynamic> createConversation({
    required String name,
    String? avatarUrl,
    bool isGroup = false,
  }) async {
    final deviceId = await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.conversations)
        .insert({
          'name': name,
          'avatar_url': avatarUrl,
          'is_group': isGroup,
          'created_by': deviceId,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select();

    // Add creator as participant
    if (response.isNotEmpty) {
      await addParticipant(
        conversationId: response[0]['id'],
        deviceId: deviceId,
        isAdmin: true,
      );
    }

    return response;
  }

  /// Get conversation by ID
  static Future<dynamic> getConversation({required String conversationId}) async {
    final response = await Supabase.instance.client
        .from(SupabaseTables.conversations)
        .select()
        .eq('id', conversationId)
        .single();
    return response;
  }

  /// Get all conversations for current device
  static Future<List<Map<String, dynamic>>> getConversations() async {
    final deviceId = await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.chatParticipants)
        .select('conversation_id, conversations(*)')
        .eq('device_id', deviceId)
        .order('created_at', ascending: false);

    // Transform response to proper format
    return response.map((item) {
      final conversation = item['conversations'] as Map<String, dynamic>;
      return {
        'id': conversation['id'],
        'deviceId': conversation['id'],
        'deviceName': conversation['name'] ?? 'Unknown',
        'nickname': conversation['name'],
        'lastMessage': '',
        'lastMessageTime': DateTime.tryParse(conversation['created_at'] ?? ''),
        'unreadCount': 0,
        'isOnline': false,
        'deviceType': 'phone',
      };
    }).toList();
  }

  /// Update conversation details
  static Future<dynamic> updateConversation({
    required String conversationId,
    String? name,
    String? avatarUrl,
  }) async {
    final Map<String, dynamic> updates = {
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final response = await Supabase.instance.client
        .from(SupabaseTables.conversations)
        .update(updates)
        .eq('id', conversationId)
        .select();
    return response;
  }

  /// Delete conversation
  static Future<void> deleteConversation({required String conversationId}) async {
    await Supabase.instance.client
        .from(SupabaseTables.conversations)
        .delete()
        .eq('id', conversationId);
  }

  /// Add participant to conversation
  static Future<dynamic> addParticipant({
    required String conversationId,
    String? deviceId,
    bool isAdmin = false,
  }) async {
    final id = deviceId ?? await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.chatParticipants)
        .insert({
          'conversation_id': conversationId,
          'device_id': id,
          'joined_at': DateTime.now().toIso8601String(),
          'is_admin': isAdmin,
        })
        .select();
    return response;
  }

  /// Remove participant from conversation
  static Future<void> removeParticipant({
    required String conversationId,
    String? deviceId,
  }) async {
    final id = deviceId ?? await _getDeviceId();
    await Supabase.instance.client
        .from(SupabaseTables.chatParticipants)
        .delete()
        .match({
          'conversation_id': conversationId,
          'device_id': id,
        });
  }

  /// Get conversation participants
  static Future<List<dynamic>> getParticipants({required String conversationId}) async {
    final response = await Supabase.instance.client
        .from(SupabaseTables.chatParticipants)
        .select()
        .eq('conversation_id', conversationId);
    return response;
  }

  // ==================== Messages ====================

  /// Send a new message
  static Future<dynamic> sendMessage(
    String content, {
    required String conversationId,
    String? messageType,
    String? attachmentUrl,
    bool isSent = true,
  }) async {
    final deviceId = await _getDeviceId();
    final username = await _getUsername();
    
    final response = await Supabase.instance.client
        .from(SupabaseTables.messages)
        .insert({
          'conversation_id': conversationId,
          'sender_device_id': deviceId,
          'sender_name': username,
          'content': content,
          'message_type': messageType ?? 'text',
          'attachment_url': attachmentUrl,
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        })
        .select();
    return response;
  }

  /// Get messages for a conversation
  static Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    final deviceId = await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.messages)
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .limit(limit)
        .range(offset, offset + limit - 1);

    // Transform response to proper format
    return response.map((msg) {
      return {
        'id': msg['id'],
        'text': msg['content'],
        'timestamp': DateTime.tryParse(msg['created_at'] ?? ''),
        'isSent': msg['sender_device_id'] == deviceId,
        'status': msg['is_read'] ? 'delivered' : 'sent',
        'senderName': msg['sender_name'] ?? 'Unknown',
      };
    }).toList();
  }

  /// Get unread message count for a conversation
  static Future<int> getUnreadCount({required String conversationId}) async {
    final deviceId = await _getDeviceId();
    final response = await Supabase.instance.client
        .from(SupabaseTables.messages)
        .select()
        .eq('conversation_id', conversationId)
        .eq('is_read', false)
        .neq('sender_device_id', deviceId);
    return response.length;
  }

  /// Mark message as read
  static Future<void> markAsRead({required String messageId}) async {
    await Supabase.instance.client
        .from(SupabaseTables.messages)
        .update({'is_read': true})
        .eq('id', messageId);
  }

  /// Mark all messages in conversation as read
  static Future<void> markConversationAsRead({required String conversationId}) async {
    final deviceId = await _getDeviceId();
    await Supabase.instance.client
        .from(SupabaseTables.messages)
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_device_id', deviceId)
        .eq('is_read', false);
  }

  /// Delete a message
  static Future<void> deleteMessage({required String messageId}) async {
    await Supabase.instance.client
        .from(SupabaseTables.messages)
        .delete()
        .eq('id', messageId);
  }

  /// Update message content
  static Future<dynamic> updateMessage({
    required String messageId,
    required String content,
  }) async {
    final response = await Supabase.instance.client
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
  static Future<List<dynamic>> searchMessages({
    required String conversationId,
    required String query,
  }) async {
    final response = await Supabase.instance.client
        .from(SupabaseTables.messages)
        .select()
        .eq('conversation_id', conversationId)
        .ilike('content', '%$query%')
        .order('created_at', ascending: false);
    return response;
  }

  /// Search users by username
  static Future<List<dynamic>> searchUsers({required String query}) async {
    final response = await Supabase.instance.client
        .from(SupabaseTables.profiles)
        .select()
        .ilike('username', '%$query%')
        .limit(20);
    return response;
  }

  // ==================== Helpers ====================

  /// Get device ID from storage
  static Future<String> _getDeviceId() async {
    // TODO: Implement device ID retrieval from storage
    // For now, generate a random ID
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get username from storage
  static Future<String> _getUsername() async {
    // TODO: Implement username retrieval from storage
    return 'User';
  }
}
