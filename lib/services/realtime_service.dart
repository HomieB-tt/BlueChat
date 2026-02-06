import 'package:supabase_flutter/supabase_flutter.dart';

/// Real-time service for BlueChat
/// Handles real-time subscriptions for messages and presence
class RealtimeService {
  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};

  RealtimeService({required SupabaseClient client}) : _client = client;

  // ==================== Channel Management ====================

  /// Create a channel for a conversation
  RealtimeChannel createConversationChannel(String conversationId) {
    final channel = _client.channel('conversation:$conversationId');
    _channels['conversation:$conversationId'] = channel;
    return channel;
  }

  /// Create a channel for messages
  RealtimeChannel createMessagesChannel(String conversationId) {
    final channel = _client.channel('messages:$conversationId');
    _channels['messages:$conversationId'] = channel;
    return channel;
  }

  /// Create a channel for presence tracking
  RealtimeChannel createPresenceChannel(String conversationId) {
    final channel = _client.channel('presence:$conversationId');
    _channels['presence:$conversationId'] = channel;
    return channel;
  }

  /// Subscribe to a channel
  void subscribe(RealtimeChannel channel, [void Function(RealtimeSubscribeStatus, dynamic)? callback]) {
    channel.subscribe(callback);
  }

  /// Unsubscribe from a specific channel
  void unsubscribe(String channelId) {
    final channel = _channels[channelId];
    if (channel != null) {
      _client.removeChannel(channel);
      _channels.remove(channelId);
    }
  }

  /// Unsubscribe from all channels
  void unsubscribeAll() {
    for (final channel in _channels.values) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }

  /// Check if subscribed to a channel
  bool isSubscribed(String channelId) {
    return _channels.containsKey(channelId);
  }

  /// Get all active channel IDs
  List<String> getActiveChannels() {
    return _channels.keys.toList();
  }

  /// Get the underlying Supabase client
  SupabaseClient get client => _client;
}
