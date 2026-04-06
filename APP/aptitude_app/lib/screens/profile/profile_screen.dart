import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analyticsProvider =
    Provider.of<AnalyticsProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await analyticsProvider.loadResults(authProvider.currentUser!.uid);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userModel = authProvider.userModel;

    final currentStreak = userModel?.currentStreak ?? 0;
    final longestStreak = userModel?.longestStreak ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      (userModel?.name ?? user?.displayName ?? 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userModel?.name ?? user?.displayName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ← NEW: streak badge shown directly on the profile header
                  // so the user sees their streak status at a glance.
                  _buildStreakBadge(currentStreak),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats section
            Consumer<AnalyticsProvider>(
              builder: (context, analyticsProvider, _) {
                final stats = analyticsProvider.getOverallStats();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Stats',
                          style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildStatRow(
                          Icons.quiz,
                          'Total Quizzes',
                          stats['totalQuizzes'].toString(),
                        ),
                        const Divider(),

                        _buildStatRow(
                          Icons.trending_up,
                          'Average Accuracy',
                          '${stats['averageAccuracy'].toStringAsFixed(1)}%',
                        ),
                        const Divider(),

                        _buildStatRow(
                          Icons.emoji_events,
                          'Best Score',
                          '${stats['bestScore'].toStringAsFixed(1)}%',
                        ),
                        const Divider(),

                        // ← CHANGED: use currentStreak from userModel
                        // (Firestore-backed) instead of LocalStorageService.
                        _buildStatRow(
                          Icons.local_fire_department,
                          'Current Streak',
                          '$currentStreak days',
                        ),
                        const Divider(),

                        // ← NEW: also show longest streak for motivation
                        _buildStatRow(
                          Icons.workspace_premium,
                          'Longest Streak',
                          '$longestStreak days',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Account section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Account'),
                    subtitle: const Text('Manage your account settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to account settings
                    },
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help or contact support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    subtitle: const Text('App version and info'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Aptitude Pro',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Text(
                          '🎯',
                          style: TextStyle(fontSize: 40),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout button
            CustomButton(
              text: 'Logout',
              onPressed: _handleLogout,
              icon: Icons.logout,
              color: Colors.red,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Streak badge shown in the profile header.
  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            streak == 0
                ? 'Start your streak today!'
                : '$streak day streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }
}