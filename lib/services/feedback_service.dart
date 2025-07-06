import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  static final _client = Supabase.instance.client;

  /// Submit feedback to the database
  static Future<void> submitFeedback({
    required String feedbackType,
    required String message,
    String? email,
  }) async {
    try {
      final user = _client.auth.currentUser;

      await _client.from('feedback').insert({
        'user_id': user?.id,
        'email': email?.trim(),
        'feedback_type': feedbackType,
        'message': message.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending', // Default status
      });
    } catch (error) {
      throw Exception('Failed to submit feedback: $error');
    }
  }

  /// Get user's feedback history (optional feature for future)
  static Future<List<Map<String, dynamic>>> getUserFeedback() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('feedback')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch feedback: $error');
    }
  }

  /// Get feedback statistics (optional feature for admins)
  static Future<Map<String, int>> getFeedbackStats() async {
    try {
      final response = await _client
          .from('feedback')
          .select('feedback_type')
          .order('created_at', ascending: false);

      final stats = <String, int>{
        'feedback': 0,
        'suggestion': 0,
        'bug_report': 0,
        'total': 0,
      };

      for (final item in response) {
        final type = item['feedback_type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
        stats['total'] = stats['total']! + 1;
      }

      return stats;
    } catch (error) {
      throw Exception('Failed to fetch feedback statistics: $error');
    }
  }
}
