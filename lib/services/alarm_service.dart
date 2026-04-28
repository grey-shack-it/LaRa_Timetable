import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/schedule.dart';
import 'package:get/get.dart'; // ✅ 추가
import '../modules/home/home_controller.dart'; // ✅ 추가

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false; // ✅ 초기화 여부 체크 변수 추가
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      print('알림 권한 요청 오류: $e');
    }

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    } catch (e) {
      print('정확한 알람 권한 요청 오류: $e');
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
    if (!_initialized) await init(); // ✅ 혹시 초기화 안 됐으면 여기서 초기화
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'schedule_alarm',
            '일정 알림',
            channelDescription: '아이들 일정 알림',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 매주 반복
        uiLocalNotificationDateInterpretation: // ✅ 추가
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // ✅ 추가
      print('알람 예약 중 오류: $e');
    }
  }

  // 알람 취소
  static Future<void> cancelAlarm(int id) async {
    if (!_initialized) await init(); // ✅ 추가
    await _notifications.cancel(id);
  }

  // 일정의 알람 전체 등록
  static Future<void> registerScheduleAlarms(Schedule schedule) async {
    // ✅ key가 null이면 알람 등록 건너뜀
    if (schedule.key == null) return;

    // 기존 알람 먼저 취소
    await cancelScheduleAlarms(schedule);

    final now = DateTime.now();

    // ✅ 아이 이름 가져오기
    final controller = Get.find<HomeController>();
    final childName = controller.getProfileName(schedule.childId);

    if (schedule.startAlarm) {
      // 시작 시간 알람 - 요일별로 다음 해당 요일 날짜 계산
      final startAlarmTime = _nextWeekday(
        schedule.dayOfWeek,
        schedule.startTime.hour,
        schedule.startTime.minute,
      ).subtract(Duration(minutes: schedule.startAlarmMinutes));

      if (startAlarmTime.isAfter(now)) {
        await scheduleAlarm(
          id: (schedule.key as int) * 10 + 1, // ✅ as int 추가
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
          id: (schedule.key as int) * 10 + 2, // ✅ as int 추가
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
    if (schedule.key == null) return; // ✅ 추가
    await cancelAlarm((schedule.key as int) * 10 + 1);
    await cancelAlarm((schedule.key as int) * 10 + 2);
  }

  // 다음 해당 요일 DateTime 계산 (dayOfWeek: 1=월 ~ 7=일)
  static DateTime _nextWeekday(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();
    // Flutter 앱의 dayOfWeek: 1=월, 7=일
    // Dart의 weekday: 1=월, 7=일 (동일)
    int daysUntil = dayOfWeek - now.weekday;
    if (daysUntil < 0) daysUntil += 7;
    if (daysUntil == 0) {
      // 오늘인 경우 시간이 지났으면 다음 주로
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
}
