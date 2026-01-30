import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for persisting app state and user preferences
class StorageService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'app_language';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyMessageAlerts = 'message_alerts';
  static const String _keyConnectionAlerts = 'connection_alerts';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyAutoDiscovery = 'auto_discovery';
  static const String _keyBackgroundScanning = 'background_scanning';
  static const String _keyMessageEncryption = 'message_encryption';
  static const String _keyAutoBackup = 'auto_backup';
  static const String _keyConnectionTimeout = 'connection_timeout';
  static const String _keyDataRetention = 'data_retention';
  static const String _keyConversations = 'conversations';
  static const String _keyDevices = 'devices';

  static SharedPreferences? _prefs;

  /// Initialize storage service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get theme mode (light/dark/system)
  static String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? 'light';
  }

  /// Set theme mode
  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(_keyThemeMode, mode);
  }

  /// Get app language
  static String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? 'English';
  }

  /// Set app language
  static Future<void> setLanguage(String language) async {
    await _prefs?.setString(_keyLanguage, language);
  }

  /// Get notifications enabled status
  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Set notifications enabled status
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  /// Get message alerts status
  static bool getMessageAlerts() {
    return _prefs?.getBool(_keyMessageAlerts) ?? true;
  }

  /// Set message alerts status
  static Future<void> setMessageAlerts(bool enabled) async {
    await _prefs?.setBool(_keyMessageAlerts, enabled);
  }

  /// Get connection alerts status
  static bool getConnectionAlerts() {
    return _prefs?.getBool(_keyConnectionAlerts) ?? true;
  }

  /// Set connection alerts status
  static Future<void> setConnectionAlerts(bool enabled) async {
    await _prefs?.setBool(_keyConnectionAlerts, enabled);
  }

  /// Get sound enabled status
  static bool getSoundEnabled() {
    return _prefs?.getBool(_keySoundEnabled) ?? true;
  }

  /// Set sound enabled status
  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySoundEnabled, enabled);
  }

  /// Get auto discovery status
  static bool getAutoDiscovery() {
    return _prefs?.getBool(_keyAutoDiscovery) ?? true;
  }

  /// Set auto discovery status
  static Future<void> setAutoDiscovery(bool enabled) async {
    await _prefs?.setBool(_keyAutoDiscovery, enabled);
  }

  /// Get background scanning status
  static bool getBackgroundScanning() {
    return _prefs?.getBool(_keyBackgroundScanning) ?? false;
  }

  /// Set background scanning status
  static Future<void> setBackgroundScanning(bool enabled) async {
    await _prefs?.setBool(_keyBackgroundScanning, enabled);
  }

  /// Get message encryption status
  static bool getMessageEncryption() {
    return _prefs?.getBool(_keyMessageEncryption) ?? true;
  }

  /// Set message encryption status
  static Future<void> setMessageEncryption(bool enabled) async {
    await _prefs?.setBool(_keyMessageEncryption, enabled);
  }

  /// Get auto backup status
  static bool getAutoBackup() {
    return _prefs?.getBool(_keyAutoBackup) ?? false;
  }

  /// Set auto backup status
  static Future<void> setAutoBackup(bool enabled) async {
    await _prefs?.setBool(_keyAutoBackup, enabled);
  }

  /// Get connection timeout
  static int getConnectionTimeout() {
    return _prefs?.getInt(_keyConnectionTimeout) ?? 30;
  }

  /// Set connection timeout
  static Future<void> setConnectionTimeout(int seconds) async {
    await _prefs?.setInt(_keyConnectionTimeout, seconds);
  }

  /// Get data retention period
  static String getDataRetention() {
    return _prefs?.getString(_keyDataRetention) ?? '30 days';
  }

  /// Set data retention period
  static Future<void> setDataRetention(String period) async {
    await _prefs?.setString(_keyDataRetention, period);
  }

  /// Save conversations
  static Future<void> saveConversations(
    List<Map<String, dynamic>> conversations,
  ) async {
    final jsonString = jsonEncode(conversations);
    await _prefs?.setString(_keyConversations, jsonString);
  }

  /// Load conversations
  static List<Map<String, dynamic>> loadConversations() {
    final jsonString = _prefs?.getString(_keyConversations);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save devices
  static Future<void> saveDevices(List<Map<String, dynamic>> devices) async {
    final jsonString = jsonEncode(devices);
    await _prefs?.setString(_keyDevices, jsonString);
  }

  /// Load devices
  static List<Map<String, dynamic>> loadDevices() {
    final jsonString = _prefs?.getString(_keyDevices);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
