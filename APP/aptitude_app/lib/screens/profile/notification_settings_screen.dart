import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _enabled = false;
  bool _isLoading = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await NotificationService.getNotificationsEnabled();
    final time = await NotificationService.getReminderTime();
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = enabled;
      _reminderTime = time;
      _isLoading = false;
    });
  }

  Future<void> _pickTime() async {
    if (kIsWeb) {
      _showMessage('Notifications are currently available on mobile only.');
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null) {
      return;
    }

    await NotificationService.setReminderTime(picked);
    if (_enabled) {
      await NotificationService.scheduleDailyReminderAt(picked);
      _showMessage('Reminder time updated.');
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _reminderTime = picked;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (kIsWeb) {
      _showMessage('Notifications are currently available on mobile only.');
      return;
    }

    if (value) {
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        _showMessage('Notification permission is required to enable reminders.');
        return;
      }
      await NotificationService.scheduleDailyReminderAt(_reminderTime);
      await NotificationService.setNotificationsEnabled(true);
      await NotificationService.showTestNotification();
      if (!mounted) {
        return;
      }
      setState(() {
        _enabled = true;
      });
      _showMessage('Daily reminders are enabled.');
      return;
    }

    await NotificationService.disableDailyReminder();
    await NotificationService.setNotificationsEnabled(false);
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = false;
    });
    _showMessage('Notifications are disabled.');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextReminder =
        NotificationService.getNextReminderDateTime(_reminderTime);
    final nextReminderText =
        '${MaterialLocalizations.of(context).formatMediumDate(nextReminder)} '
        '${MaterialLocalizations.of(context).formatTimeOfDay(_reminderTime)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: SwitchListTile(
                      value: _enabled,
                      title: const Text('Daily Practice Reminder'),
                      subtitle: Text(
                        _enabled
                            ? 'Next reminder: $nextReminderText'
                            : 'Get a daily notification to keep your quiz streak active.',
                      ),
                      onChanged: _toggleNotifications,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Reminder time'),
                      subtitle: Text(
                        'Daily at ${_reminderTime.format(context)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pickTime,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Send test notification now'),
                      subtitle: const Text(
                        'Use this to verify notifications are working on this device.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        if (kIsWeb) {
                          _showMessage(
                            'Notifications are currently available on mobile only.',
                          );
                          return;
                        }
                        await NotificationService.showTestNotification();
                        _showMessage('Test notification sent.');
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('How reminders work'),
                      subtitle: Text(
                        'After enabling, the app schedules one repeating daily reminder. '
                        'You can disable it anytime from this page.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
