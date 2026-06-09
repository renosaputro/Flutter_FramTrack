import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      debugPrint(
        '⏰ [NotificationService] Timezone terdeteksi: ${timeZoneInfo.identifier}',
      );
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      debugPrint(
        '⏰ [NotificationService] Timezone fallback ke Asia/Jakarta karena error: $e',
      );
    }

    const channel = AndroidNotificationChannel(
      'farmtrack_reminders_v3',
      'Pengingat FarmTrack',
      description: 'Notifikasi pengingat tanaman',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
      debugPrint(
        '⏰ [NotificationService] AndroidNotificationChannel v3 berhasil dibuat.',
      );

      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
      debugPrint(
        '⏰ [NotificationService] Izin notifikasi dan exact alarm telah diminta.',
      );
    }

    _initialized = true;
    debugPrint('⏰ [NotificationService] Inisialisasi berhasil.');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'farmtrack_reminders_v3',
      'Pengingat FarmTrack',
      channelDescription: 'Notifikasi pengingat tanaman',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
    debugPrint(
      '⏰ [NotificationService] Menampilkan notifikasi instan: "$title"',
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      debugPrint(
        '⏰ [NotificationService] Scheduled time $scheduledTime is in the past — showing immediately.',
      );
      await showNotification(id: id, title: title, body: body);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'farmtrack_reminders_v3',
      'Pengingat FarmTrack',
      channelDescription: 'Notifikasi pengingat tanaman',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);

    final targetTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    debugPrint(
      '⏰ [NotificationService] Menjadwalkan "$title" pada TZDateTime: $targetTZ (Local: $scheduledTime, ID: $id)',
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        targetTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint(
        '✅ [NotificationService] Berhasil menjadwalkan "$title" via zonedSchedule.',
      );
    } catch (e) {
      debugPrint(
        '❌ [NotificationService] Error saat memanggil zonedSchedule: $e',
      );
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    debugPrint('⏰ [NotificationService] Membatalkan notifikasi dengan ID: $id');
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('⏰ [NotificationService] Membatalkan seluruh notifikasi.');
  }
}
