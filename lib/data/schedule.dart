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

  Schedule({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    this.memo = '', // 👈 필수 항목으로 추가
    this.iconName,
    this.colorValue = 0xFFC09FF8, // 기본값은 기존 보라색으로 설정
  });
}
