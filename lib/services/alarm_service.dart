import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/schedule.dart';
import 'package:get/get.dart';
import '../modules/home/home_controller.dart';
import 'package:flutter/foundation.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings: initSettings);

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('알림 권한 요청 오류: $e');
    }

    _initialized = true;
  }

  // 알람 예약
  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) await init();
    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'schedule_alarm',
            '일정 알림',
            channelDescription: '아이들 일정 알림',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('알람 예약 중 오류: $e');
    }
  }

  // 알람 취소
  static Future<void> cancelAlarm(int id) async {
    if (!_initialized) await init();
    await _notifications.cancel(id: id);
  }

  // 일정의 알람 전체 등록
  static Future<void> registerScheduleAlarms(Schedule schedule) async {
    if (schedule.key == null) return;

    await cancelScheduleAlarms(schedule);

    final now = DateTime.now();
    final controller = Get.find<HomeController>();
    final childName = controller.getProfileName(schedule.childId);

    if (schedule.startAlarm) {
      final startAlarmTime = _nextWeekday(
        schedule.dayOfWeek,
        schedule.startTime.hour,
        schedule.startTime.minute,
      ).subtract(Duration(minutes: schedule.startAlarmMinutes));

      if (startAlarmTime.isAfter(now)) {
        await scheduleAlarm(
          id: (schedule.key as int) * 10 + 1,
          title: '📚 곧 시작해요!',
          body:
              '${schedule.startAlarmMinutes}분 후에 $childName의 ${schedule.title} 수업 시작이에요. 가방 챙기셨죠?',
          scheduledTime: startAlarmTime,
        );
      }
    }

    if (schedule.endAlarm) {
      final endAlarmTime = _nextWeekday(
        schedule.dayOfWeek,
        schedule.endTime.hour,
        schedule.endTime.minute,
      ).subtract(Duration(minutes: schedule.endAlarmMinutes));

      if (endAlarmTime.isAfter(now)) {
        await scheduleAlarm(
          id: (schedule.key as int) * 10 + 2,
          title: '🏁 곧 끝나요!',
          body:
              '${schedule.endAlarmMinutes}분 후에 $childName의 ${schedule.title} 수업이 끝나요. 슬슬 마중을 나가 볼까요?',
          scheduledTime: endAlarmTime,
        );
      }
    }
  }

  // 일정의 알람 전체 취소
  static Future<void> cancelScheduleAlarms(Schedule schedule) async {
    if (schedule.key == null) return;
    final int key = schedule.key is int
        ? schedule.key as int
        : int.tryParse(schedule.key.toString()) ?? 0;
    await cancelAlarm(key * 10 + 1);
    await cancelAlarm(key * 10 + 2);
  }

  // 다음 해당 요일 DateTime 계산
  static DateTime _nextWeekday(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();
    int daysUntil = dayOfWeek - now.weekday;
    if (daysUntil < 0) daysUntil += 7;
    if (daysUntil == 0) {
      final todayTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (todayTime.isBefore(now)) daysUntil = 7;
    }
    final targetDate = now.add(Duration(days: daysUntil));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
  }

  // 결제일 알림 등록
  static Future<void> schedulePaymentAlarm({
    required String academyId,
    required String academyName,
    required String childName,
    required int paymentDay,
    required int alarmDaysBefore,
    required int alarmHour,
    required int alarmMinute,
  }) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    int targetDay = paymentDay - alarmDaysBefore;
    if (targetDay < 1) targetDay = 1;

    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      targetDay,
      alarmHour,
      alarmMinute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        now.year,
        now.month + 1,
        targetDay,
        alarmHour,
        alarmMinute,
      );
    }

    final int notifId = academyId.hashCode.abs();

    try {
      await _notifications.zonedSchedule(
        id: notifId,
        title: '💰 학원비 결제일 알려드려요!',
        body: '$alarmDaysBefore일 후 $childName의 $academyName 학원비 납부 잊지마세요!',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'payment_alarm',
            '결제일 알림',
            channelDescription: '학원 결제일 알림',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
      debugPrint('결제일 알림 등록: $academyName / $scheduledDate');
    } catch (e) {
      debugPrint('결제일 알림 예약 오류: $e');
    }
  }

  // 결제일 알림 취소
  static Future<void> cancelPaymentAlarm(String academyId) async {
    if (!_initialized) await init();
    await _notifications.cancel(id: academyId.hashCode.abs());
  }
}
