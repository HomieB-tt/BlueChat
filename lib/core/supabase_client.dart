import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

/// Supabase client configuration and initialization
/// 
/// This singleton class manages the Supabase client instance
/// and provides easy access to database operations.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() => _instance;
  
  SupabaseService._internal();
  
  /// Initialize Supabase with credentials from environment config
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  }
  
  /// Get the current user (null if not authenticated)
  User? get currentUser => Supabase.instance.client.auth.currentUser;
  
  /// Get the current session
  Session? get currentSession => Supabase.instance.client.auth.currentSession;
  
  /// Get the underlying Supabase client
  SupabaseClient get client => Supabase.instance.client;
}

/// Extension methods for easy access
extension SupabaseExtensions on SupabaseService {
  /// Get the underlying Supabase Flutter client
  SupabaseClient get client => Supabase.instance.client;
}
