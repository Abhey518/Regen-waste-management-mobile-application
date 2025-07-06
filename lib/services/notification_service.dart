import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all notifications for the current user
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .or('user_id.eq.$userId,user_id.is.null') // User-specific or global notifications
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .or('user_id.eq.$userId,user_id.is.null')
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select('id')
          .or('user_id.eq.$userId,user_id.is.null')
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Admin: Create a new notification
  Future<void> createNotification({
    required String title,
    required String message,
    String type = 'general',
    String? userId, // null for global notifications
    String icon = 'notifications',
    int priority = 1,
    DateTime? expiresAt,
    String? actionUrl,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'title': title,
        'message': message,
        'type': type,
        'user_id': userId,
        'icon': icon,
        'priority': priority,
        'expires_at': expiresAt?.toIso8601String(),
        'action_url': actionUrl,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Admin: Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all notifications: $e');
    }
  }

  // Admin: Update notification
  Future<void> updateNotification(
      String notificationId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('notifications')
          .update(updates)
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  // Admin: Delete notification
  Future<void> adminDeleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Listen to real-time notifications
  Stream<List<NotificationModel>> watchUserNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => (data as List)
            .where(
                (item) => item['user_id'] == userId || item['user_id'] == null)
            .map((item) => NotificationModel.fromJson(item))
            .toList());
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final String icon;
  final String? actionUrl;
  final int priority;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    required this.icon,
    this.actionUrl,
    required this.priority,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'] ?? false,
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      icon: json['icon'] ?? 'notifications',
      actionUrl: json['action_url'],
      priority: json['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'icon': icon,
      'action_url': actionUrl,
      'priority': priority,
    };
  }

  // Helper method to get icon data based on type
  String get iconName {
    switch (type) {
      case 'pickup':
        return 'schedule';
      case 'urgent':
        return 'priority_high';
      case 'announcement':
        return 'campaign';
      default:
        return icon;
    }
  }

  // Helper method to check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Helper method to get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
