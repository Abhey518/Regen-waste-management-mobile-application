import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class ProfileWindow extends StatelessWidget {
  const ProfileWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 28,
                color: theme.appBarTheme.iconTheme?.color,
              ),
              onPressed: () {
                themeProvider.toggleTheme(!isDarkMode);
              },
            ),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'User Name',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'user@gmail.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileItem(context, Icons.person_outline, 'Edit Profile'),
            _buildProfileItem(context, Icons.comment, 'Feedback & Suggestions'),
            _buildProfileItem(context, Icons.settings, 'Settings'),
            _buildProfileItem(context, Icons.group, 'About Us'),
            _buildProfileItem(context, Icons.logout, 'Log Out', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String text,
      {bool isLogout = false}) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : theme.colorScheme.primary,
        ),
        title: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isLogout ? Colors.red : theme.colorScheme.onSurface,
            fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isLogout
            ? null
            : Icon(
                Icons.chevron_right,
                color: Color.alphaBlend(
                  theme.colorScheme.onSurface.withAlpha(153),
                  theme.cardColor,
                ),
              ),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
