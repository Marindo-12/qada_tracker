import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationPreferences {
  final bool morningEnabled;
  final bool perPrayerEnabled;
  final int morningHour;
  final int morningMinute;

  const NotificationPreferences({
    this.morningEnabled = false,
    this.perPrayerEnabled = false,
    this.morningHour = 8,
    this.morningMinute = 0,
  });

  bool get hasEnabledReminder => morningEnabled || perPrayerEnabled;

  NotificationPreferences copyWith({
    bool? morningEnabled,
    bool? perPrayerEnabled,
    int? morningHour,
    int? morningMinute,
  }) {
    return NotificationPreferences(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      perPrayerEnabled: perPrayerEnabled ?? this.perPrayerEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
    );
  }
}

class QadaNotificationService {
  QadaNotificationService._();

  static const _morningKey = 'qada.notifications.morningEnabled';
  static const _perPrayerKey = 'qada.notifications.perPrayerEnabled';
  static const _morningHourKey = 'qada.notifications.morningHour';
  static const _morningMinuteKey = 'qada.notifications.morningMinute';

  static const _morningId = 7100;
  static const _perPrayerBaseId = 7200;
  static const _channelId = 'qada_daily_reminders';
  static const _channelName = 'Qada daily reminders';
  static const _channelDescription = 'Daily reminders for the qada prayer plan';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _perPrayerTimes = [
    (prayer: 'الفجر', hour: 5, minute: 0),
    (prayer: 'الظهر', hour: 13, minute: 0),
    (prayer: 'العصر', hour: 16, minute: 30),
    (prayer: 'المغرب', hour: 19, minute: 0),
    (prayer: 'العشاء', hour: 21, minute: 0),
  ];

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    await _configureLocalTimezone();
  }

  static Future<void> _configureLocalTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (e) {
      debugPrint('Unable to resolve local timezone for notifications: $e');
    }
  }

  static NotificationPreferences loadPreferences(SharedPreferences prefs) {
    return NotificationPreferences(
      morningEnabled: prefs.getBool(_morningKey) ?? false,
      perPrayerEnabled: prefs.getBool(_perPrayerKey) ?? false,
      morningHour: prefs.getInt(_morningHourKey) ?? 8,
      morningMinute: prefs.getInt(_morningMinuteKey) ?? 0,
    );
  }

  static Future<void> savePreferences(
    SharedPreferences prefs,
    NotificationPreferences preferences,
  ) async {
    await prefs.setBool(_morningKey, preferences.morningEnabled);
    await prefs.setBool(_perPrayerKey, preferences.perPrayerEnabled);
    await prefs.setInt(_morningHourKey, preferences.morningHour);
    await prefs.setInt(_morningMinuteKey, preferences.morningMinute);
  }

  static Future<void> saveAndSchedule({
    required SharedPreferences prefs,
    required NotificationPreferences preferences,
    required int dailyTarget,
  }) async {
    await savePreferences(prefs, preferences);
    await scheduleDailyReminders(
      preferences: preferences,
      dailyTarget: dailyTarget,
    );
  }

  static Future<void> scheduleDailyReminders({
    required NotificationPreferences preferences,
    required int dailyTarget,
  }) async {
    await requestPermissions();
    await cancelQadaReminders();

    if (!preferences.hasEnabledReminder) return;

    if (preferences.morningEnabled) {
      await _scheduleDaily(
        id: _morningId,
        hour: preferences.morningHour,
        minute: preferences.morningMinute,
        title: 'تذكير ورد القضاء',
        body: 'هدفك اليومي: $dailyTarget يوم قضاء. ثبت وردك اليوم بهدوء.',
      );
    }

    if (preferences.perPrayerEnabled) {
      for (var i = 0; i < _perPrayerTimes.length; i++) {
        final reminder = _perPrayerTimes[i];
        await _scheduleDaily(
          id: _perPrayerBaseId + i,
          hour: reminder.hour,
          minute: reminder.minute,
          title: 'تذكير بعد صلاة ${reminder.prayer}',
          body: 'إن كان وقتك مناسبا، أضف شيئا من قضاء اليوم.',
        );
      }
    }
  }

  static Future<void> cancelQadaReminders() async {
    await _plugin.cancel(_morningId);
    for (var i = 0; i < _perPrayerTimes.length; i++) {
      await _plugin.cancel(_perPrayerBaseId + i);
    }
  }

  static Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macos?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextDailyInstance(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextDailyInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
