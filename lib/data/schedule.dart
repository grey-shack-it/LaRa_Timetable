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

  Schedule({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.memo, // 👈 필수 항목으로 추가
    this.iconName,
  });
}
