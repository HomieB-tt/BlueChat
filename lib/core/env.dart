class Environment {
  static const String supabaseUrl = 'https://xgnqvhdfemyvjkrqvpou.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbnF2aGRmZW15dmprcnF2cG91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3OTI2MDQsImV4cCI6MjA4NTM2ODYwNH0.FsOUd9zTEg04o-ENkbG1RjnEexgaqQGFVVNG0kJUiT0';
}

/// Supabase table names used in the app
class SupabaseTables {
  /// Users profile table (identified by device ID, no auth)
  static const String profiles = 'profiles';

  /// Conversations table
  static const String conversations = 'conversations';

  /// Messages table
  static const String messages = 'messages';

  /// Chat participants table
  static const String chatParticipants = 'chat_participants';
}

/// Supabase storage bucket names
class SupabaseBuckets {
  /// Profile avatars bucket
  static const String avatars = 'avatars';

  /// Chat attachments bucket
  static const String attachments = 'attachments';
}

/// BLE Constants for Bluetooth device discovery
class BLEConstants {
  // BlueChat service UUID for device discovery and communication
  static const String serviceUuid = '0000FEED-0000-1000-8000-00805F9B34FB';

  // Characteristic UUIDs
  static const String messageCharacteristic = '0000FEED-0000-1000-8000-00805F9B34FB';
  static const String deviceInfoCharacteristic = '0000180A-0000-1000-8000-00805F9B34FB';

  // Transmission power for RSSI calculation
  static const int txPowerLevel = -59;
}
