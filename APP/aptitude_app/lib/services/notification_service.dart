import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../utils/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    tz_data.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final androidGranted =
        await androidImplementation?.requestNotificationsPermission() ?? true;
    // On newer Android versions, exact alarms may need a separate user approval.
    // If denied, we can still schedule inexact reminders.
    await androidImplementation?.requestExactAlarmsPermission();
    final iosGranted =
        await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
            true;

    return androidGranted && iosGranted;
  }

  static Future<void> showTestNotification() async {
    if (kIsWeb) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'aptitude_general_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      9999,
      'Aptitude Pro',
      'Notifications are enabled successfully.',
      details,
    );
  }

  static Future<void> scheduleDailyReminderAt(TimeOfDay time) async {
    if (kIsWeb) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'aptitude_daily_channel',
      'Daily Reminders',
      channelDescription: 'Daily reminder to practice aptitude quizzes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final canUseExact =
        await androidImplementation?.canScheduleExactNotifications() ?? false;
    final scheduleMode = canUseExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _plugin.cancel(_dailyReminderId);
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Time to practice!',
      'Take a quick aptitude quiz to keep your streak alive.',
      _nextInstanceOfTime(time),
      details,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleDailyReminder() async {
    final time = await getReminderTime();
    return scheduleDailyReminderAt(time);
  }

  static Future<void> disableDailyReminder() async {
    if (kIsWeb) {
      return;
    }
    await _plugin.cancel(_dailyReminderId);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyNotificationsEnabled) ?? false;
  }

  static Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyNotificationHour, time.hour);
    await prefs.setInt(AppConstants.keyNotificationMinute, time.minute);
  }

  static Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(AppConstants.keyNotificationHour) ?? 20;
    final minute = prefs.getInt(AppConstants.keyNotificationMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static DateTime getNextReminderDateTime(TimeOfDay time) {
    final now = DateTime.now();
    var next = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }
}
