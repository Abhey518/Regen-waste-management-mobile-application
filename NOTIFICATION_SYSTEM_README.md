# Notification System Documentation

## Overview
The notification system allows administrators to send notifications to users and users to view their notifications with real-time updates via Supabase.

## Database Setup

### 1. Create the notifications table
Run the SQL script:
```bash
database/create_notifications_table.sql
```

### 2. Update users table for admin roles
Run the SQL script:
```bash
database/update_users_table_for_roles.sql
```

### 3. Set admin users
After running the scripts, update specific users to have admin role:
```sql
UPDATE users SET role = 'admin' WHERE email = 'youradmin@email.com';
```

## Features

### User Features (NotificationsWindow)
- ✅ View all notifications (user-specific + global)
- ✅ Real-time updates
- ✅ Mark notifications as read
- ✅ Mark all notifications as read
- ✅ Delete notifications (swipe to delete)
- ✅ Visual indicators for unread notifications
- ✅ Different icons and colors based on notification type
- ✅ Priority indicators for urgent notifications
- ✅ Pull-to-refresh
- ✅ Responsive design with theme support

### Admin Features (AdminNotificationPanel)
- ✅ Create new notifications
- ✅ View all notifications
- ✅ Delete notifications
- ✅ Set notification types (general, pickup, urgent, announcement)
- ✅ Set priority levels (1-5)
- ✅ Choose from predefined icons
- ✅ Set expiration dates
- ✅ Send to specific users or globally
- ✅ Add action URLs
- ✅ Real-time management

## File Structure

```
lib/
├── services/
│   └── notification_service.dart      # Service for CRUD operations
├── Screens/Sub Screens/
│   └── notifications_window.dart      # User notification view
└── admin/
    └── admin_notification_panel.dart  # Admin panel for managing notifications
    
database/
├── create_notifications_table.sql    # Creates notifications table
└── update_users_table_for_roles.sql  # Adds role support to users table
```

## Usage

### For Users
1. Navigate to notifications from the main menu
2. View all notifications (unread ones are highlighted)
3. Tap notification to mark as read
4. Swipe left to delete notifications
5. Use "Mark all as read" button in app bar
6. Pull down to refresh

### For Admins
1. Access `AdminNotificationPanel` (you'll need to add navigation to this)
2. Use the + button to create new notifications
3. Fill in the form with notification details
4. Choose notification type, priority, and icon
5. Set expiration date if needed
6. Send to specific users or leave User ID empty for global notifications

## Notification Types

- **general**: Default notifications
- **pickup**: Garbage collection related
- **urgent**: High priority notifications (shown with red badge)
- **announcement**: System announcements

## Priority Levels

- **1-3**: Normal priority
- **4-5**: Urgent priority (shown with "Urgent" badge)

## Icons Available

- notifications, schedule, priority_high, campaign, recycling
- local_shipping, check_circle, system_update, celebration, build

## Integration Example

### Add to your main navigation:
```dart
// In your navigation drawer or menu
ListTile(
  leading: Icon(Icons.notifications),
  title: Text('Notifications'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsWindow(),
      ),
    );
  },
),

// For admin users only
if (userRole == 'admin')
  ListTile(
    leading: Icon(Icons.admin_panel_settings),
    title: Text('Manage Notifications'),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminNotificationPanel(),
        ),
      );
    },
  ),
```

### Check unread notifications count:
```dart
final notificationService = NotificationService();
final unreadCount = await notificationService.getUnreadCount();
// Use this to show badge on notification icon
```

## Real-time Updates

The system supports real-time updates using Supabase's real-time features. Notifications will appear instantly when created by admins.

## Security

- Row Level Security (RLS) is enabled
- Users can only see their own notifications + global notifications
- Only admin users can create/manage notifications
- All operations are properly authenticated

## Sample Notifications

The SQL script includes sample notifications. You can customize or remove these as needed.

## Troubleshooting

### Common Issues:

1. **"Failed to create notification" error**
   - Ensure the user has admin role in the database
   - Check Supabase connection

2. **Notifications not appearing**
   - Verify RLS policies are correctly set
   - Check if user is authenticated

3. **Real-time updates not working**
   - Ensure Supabase real-time is enabled in your project
   - Check network connectivity

### Enable Real-time in Supabase:
1. Go to your Supabase dashboard
2. Navigate to Settings > API
3. Enable Real-time for the notifications table

## Future Enhancements

- Push notifications using Firebase Cloud Messaging
- Notification categories and filtering
- Bulk notification operations
- Notification templates
- Scheduled notifications
- Analytics and read receipts
