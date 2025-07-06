import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme_provider.dart';
import 'feedback_screen.dart';
import '../../services/user_service.dart';

class ProfileWindow extends StatefulWidget {
  const ProfileWindow({super.key});

  @override
  State<ProfileWindow> createState() => _ProfileWindowState();
}

class _ProfileWindowState extends State<ProfileWindow> {
  String? userName;
  String? userEmail;
  bool isLoading = true;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get user profile from the users table
      userProfile = await UserService.getUserProfile();

      setState(() {
        userName = UserService.formatUserName(userProfile);
        userEmail = UserService.formatUserEmail(userProfile);
        isLoading = false;
      });
    } catch (e) {
      // Fallback to auth user data if profile doesn't exist
      final user = Supabase.instance.client.auth.currentUser;
      setState(() {
        userName = user?.email?.split('@')[0] ?? 'User';
        userEmail = user?.email ?? 'No email';
        isLoading = false;
      });

      debugPrint('Error loading user profile: $e');
    }
  }

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
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        userName != null && userName!.isNotEmpty
                            ? userName![0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const CircularProgressIndicator()
              else ...[
                Text(
                  userName ?? 'User Name',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userEmail ?? 'user@gmail.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildProfileItem(context, Icons.person_outline, 'Edit Profile'),
              _buildProfileItem(
                  context, Icons.comment, 'Feedback & Suggestions', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackScreen()),
                );
              }),
              _buildProfileItem(context, Icons.settings, 'Settings'),
              _buildProfileItem(context, Icons.group, 'About Us'),
              _buildProfileItem(context, Icons.logout, 'Log Out',
                  isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String text,
      {bool isLogout = false, VoidCallback? onTap}) {
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
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
