import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 0)
class Schedule extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  int dayOfWeek;

  @HiveField(4)
  String? iconName;

  @HiveField(5) // memo 필드 추가
  String memo;

  @HiveField(6) // 새로운 번호 6번 부여
  int colorValue; // 색상을 숫자(int) 형태로 저장합니다.

  @HiveField(7) // ✅ 새로 추가
  String childId; // 어떤 아이의 일정인지 구분

  @HiveField(8)
  bool startAlarm; // 시작 시간 알람 on/off

  @HiveField(9)
  int startAlarmMinutes; // 시작 몇 분 전 알람

  @HiveField(10)
  bool endAlarm; // 종료 시간 알람 on/off

  @HiveField(11)
  int endAlarmMinutes; // 종료 몇 분 전 알람

  Schedule({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    this.memo = '', // 👈 필수 항목으로 추가
    this.iconName,
    this.colorValue = 0xFFC09FF8, // 기본값은 기존 보라색으로 설정
    this.childId = 'default', // 기본값은 'default'로 설정
    this.startAlarm = false,
    this.startAlarmMinutes = 10,
    this.endAlarm = false,
    this.endAlarmMinutes = 10,
  });
}
