import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/schedule.dart';

class HomeController extends GetxController {
  final RxList<Schedule> schedules = <Schedule>[].obs;
  var now = DateTime.now().obs;

  RxInt startHour = 7.obs;
  RxInt endHour = 21.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();

    // 🎯 시간을 실시간으로 업데이트하는 타이머
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      now.value = DateTime.now();
    });
  }

  // 🎯 화면 범위를 계산하고 UI를 새로고침하는 핵심 함수
  void refreshUI() {
    int min = 7;
    int max = 21;

    for (var s in schedules) {
      if (s.startTime.hour < min) min = s.startTime.hour;
      int endH = s.endTime.hour;
      if (s.endTime.minute > 0) endH++;
      if (endH > max) max = endH;
    }

    startHour.value = min.clamp(0, 23);
    endHour.value = max.clamp(1, 24);

    // 🔥 리스트 전체를 새로고침하여 Obx가 화면을 다시 그리게 함
    schedules.refresh();
  }

  void loadSchedules() {
    var box = Hive.box<Schedule>('schedules');
    schedules.assignAll(box.values.toList());
    refreshUI(); // 로드 후 화면 갱신
  }

  void addSchedule(
    String title,
    DateTime start,
    DateTime end,
    int day,
    String memo,
    String iconName,
  ) {
    var box = Hive.box<Schedule>('schedules');
    final newSchedule = Schedule(
      title: title,
      startTime: start,
      endTime: end,
      dayOfWeek: day,
      memo: memo,
      iconName: iconName,
    );

    box.add(newSchedule); // 1. Hive 저장

    // 🔥 [수정] 단순히 add 하는 대신, 박스의 전체 내용을 다시 불러와서 '완벽한 동기화'를 보장합니다.
    schedules.assignAll(box.values.toList());

    // 🔥 [수정] GetX에게 주소값이 바뀌었음을 알리는 가장 강력한 방법
    schedules.value = List.from(schedules);

    refreshUI();
    update(); // 2중 안전 장치
  }

  void deleteSchedule(Schedule schedule) {
    schedule.delete(); // Hive 삭제
    schedules.remove(schedule);
    schedules.refresh(); // 👈 삭제 후 즉시 화면 갱신 호출
  }

  void updateScheduleTime(Schedule schedule, int day, double localY) {
    int totalMinutes = localY.toInt();
    int hour = totalMinutes ~/ 60;
    int minute = (totalMinutes % 60) ~/ 10 * 10;

    final duration = schedule.endTime.difference(schedule.startTime);

    schedule.dayOfWeek = day;
    schedule.startTime = DateTime(2024, 1, 1, hour.clamp(0, 23), minute);
    schedule.endTime = schedule.startTime.add(duration);

    schedule.save().then((_) {
      refreshUI(); // 👈 수정 후 즉시 화면 갱신 호출
    });
  }
}
