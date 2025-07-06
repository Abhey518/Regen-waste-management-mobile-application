import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _client = Supabase.instance.client;

  /// Get user profile data from the users table
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _client.from('users').select('*').eq('id', user.id).single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Get user's full name from profile data
  static String formatUserName(Map<String, dynamic>? userProfile) {
    if (userProfile == null) return 'User';

    final firstName = userProfile['first_name']?.toString() ?? '';
    final lastName = userProfile['last_name']?.toString() ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }

    return 'User';
  }

  /// Get user's email with fallback to auth email
  static String formatUserEmail(Map<String, dynamic>? userProfile) {
    final user = _client.auth.currentUser;

    // Try to get email from profile first
    if (userProfile != null && userProfile['email'] != null) {
      return userProfile['email'].toString();
    }

    // Fallback to auth email
    if (user?.email != null) {
      return user!.email!;
    }

    return 'No email';
  }

  /// Update user profile data
  static Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _client.from('users').update(updates).eq('id', user.id);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  /// Check if user has a profile in the users table
  static Future<bool> hasUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response =
          await _client.from('users').select('id').eq('id', user.id).limit(1);

      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }
}
