import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/env.dart';

/// User service for BlueChat
/// Manages user identity using device Bluetooth name instead of authentication
///
/// Since this is a Bluetooth-based chat app, users are identified by their
/// device's Bluetooth name rather than traditional authentication.
class UserService {
  static const String _prefKeyDeviceId = 'device_id';
  static const String _prefKeyUsername = 'username';
  static const String _prefKeyUserId = 'user_id';

  String? _deviceId;
  String? _username;
  String? _userId;

  /// Get device ID (unique identifier for this device)
  Future<String> get deviceId async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_prefKeyDeviceId);

    if (_deviceId == null) {
      // Generate a new device ID
      _deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_prefKeyDeviceId, _deviceId!);
    }

    return _deviceId!;
  }

  /// Get username (defaults to device Bluetooth name)
  Future<String> get username async {
    if (_username != null) return _username!;

    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_prefKeyUsername);

    if (_username == null) {
      // Fallback to device ID if no username set
      _username = 'User_${(await deviceId).substring(0, 6)}';
      await prefs.setString(_prefKeyUsername, _username!);
    }

    return _username!;
  }

  /// Set username
  Future<void> setUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUsername, name);
    _username = name;

    // Also update in Supabase if available
    try {
      final userId = await this.userId;
      await Supabase.instance.client.from(SupabaseTables.profiles).upsert({
        'id': userId,
        'username': name,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail - local storage is primary
    }
  }

  /// Get user ID (derived from device ID for Supabase)
  Future<String> get userId async {
    if (_userId != null) return _userId!;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_prefKeyUserId);

    if (_userId == null) {
      // Create a UUID-like ID from device ID
      final devId = await deviceId;
      _userId = 'dev_${devId}_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_prefKeyUserId, _userId!);
    }

    return _userId!;
  }

  /// Initialize user profile in Supabase
  Future<void> initializeProfile() async {
    final userId = await this.userId;
    final userName = await username;

    try {
      await Supabase.instance.client.from(SupabaseTables.profiles).upsert({
        'id': userId,
        'username': userName,
        'device_id': await deviceId,
        'is_online': true,
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Profile creation failed, will retry later
    }
  }

  /// Update online status
  Future<void> setOnlineStatus({required bool isOnline}) async {
    final userId = await this.userId;

    try {
      await Supabase.instance.client
          .from(SupabaseTables.profiles)
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      // Silently fail
    }
  }

  /// Get user profile from Supabase
  Future<dynamic> getProfile() async {
    final userId = await this.userId;

    try {
      final response = await Supabase.instance.client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_prefKeyUsername);
  }

  /// Clear all user data (for logout/reset)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyUsername);
    _username = null;
  }
}

/// Extension to get device Bluetooth name
/// Note: This is a placeholder. Actual Bluetooth name retrieval
/// should be implemented using flutter_blue_plus or similar package.
extension DeviceName on UserService {
  static Future<String> getBluetoothName() async {
    // TODO: Implement actual Bluetooth name retrieval
    // For now, return a default
    return 'BlueChat_${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}
