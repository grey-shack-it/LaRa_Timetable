import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/schedule.dart';
import 'package:flutter/material.dart';
import '../../services/alarm_service.dart'; // ✅ 추가

class ChildProfile {
  String id;
  String name;

  ChildProfile({required this.id, required this.name});
}

class HomeController extends GetxController {
  final RxList<Schedule> schedules = <Schedule>[].obs;
  var now = DateTime.now().obs;

  RxInt startHour = 7.obs;
  RxInt endHour = 21.obs;

  // ✅ 프로필 관련 추가
  final RxList<ChildProfile> profiles = <ChildProfile>[
    ChildProfile(id: 'default', name: '첫째'), // 기본 프로필
  ].obs;
  final RxString selectedChildId = 'default'.obs;
  final RxBool isOverlapView = false.obs;

  static const List<Color> profileColors = [
    Color.fromARGB(255, 28, 207, 109),
    Color.fromARGB(255, 247, 147, 17),
    Color.fromARGB(255, 5, 172, 238),
    Color.fromARGB(255, 67, 117, 255),
    Color.fromARGB(255, 218, 233, 15),
  ];

  Color getProfileColor(String childId) {
    final index = profiles.indexWhere((p) => p.id == childId);
    if (index < 0) return profileColors[0];
    return profileColors[index % profileColors.length];
  }

  String getProfileName(String childId) {
    final profile = profiles.firstWhereOrNull((p) => p.id == childId);
    return profile?.name ?? '';
  }

  bool isOverlappingWithOthers(Schedule target) {
    return schedules.any((s) {
      if (s == target) return false; // 자기 자신 제외
      if (s.childId == target.childId) return false; // 같은 아이 제외
      if (s.dayOfWeek != target.dayOfWeek) return false; // 다른 요일 제외
      // 시간 겹침 확인
      return target.startTime.isBefore(s.endTime) &&
          target.endTime.isAfter(s.startTime);
    });
  }

  List<Schedule> get displaySchedules =>
      isOverlapView.value ? schedules.toList() : currentSchedules;

  // 현재 선택된 아이의 일정만 필터링
  List<Schedule> get currentSchedules =>
      schedules.where((s) => s.childId == selectedChildId.value).toList();

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      now.value = DateTime.now();
    });
  }

  // ✅ 프로필 추가
  void addProfile(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    profiles.add(ChildProfile(id: id, name: name));
  }

  // ✅ 프로필 이름 수정
  void updateProfile(String id, String newName) {
    final index = profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      profiles[index].name = newName;
      profiles.refresh();
    }
  }

  // ✅ 프로필 삭제
  void deleteProfile(String id) {
    if (profiles.length <= 1) return; // 최소 1명은 유지
    // 해당 아이 일정도 같이 삭제
    final toDelete = schedules.where((s) => s.childId == id).toList();
    for (var s in toDelete) {
      s.delete();
    }
    schedules.removeWhere((s) => s.childId == id);
    profiles.removeWhere((p) => p.id == id);
    // 삭제된 아이가 현재 선택된 아이면 첫 번째로 전환
    if (selectedChildId.value == id) {
      selectedChildId.value = profiles.first.id;
    }
    refreshUI();
  }

  void refreshUI() {
    int min = 7;
    int max = 21;

    for (var s in displaySchedules) {
      // ✅ displaySchedules로 변경
      if (s.startTime.hour < min) min = s.startTime.hour;
      int endH = s.endTime.hour;
      if (s.endTime.minute > 0) endH++;
      if (endH > max) max = endH;
    }

    startHour.value = min.clamp(0, 23);
    endHour.value = max.clamp(1, 24);
    schedules.refresh();
  }

  void loadSchedules() {
    var box = Hive.box<Schedule>('schedules');
    schedules.assignAll(box.values.toList());
    refreshUI();
  }

  Future<void> addSchedule(
    String title,
    DateTime start,
    DateTime end,
    int day,
    String memo,
    String iconName,
    int colorValue, {
    bool startAlarm = false,
    int startAlarmMinutes = 10,
    bool endAlarm = false,
    int endAlarmMinutes = 10,
  }) async {
    var box = Hive.box<Schedule>('schedules');
    final newSchedule = Schedule(
      title: title,
      startTime: start,
      endTime: end,
      dayOfWeek: day,
      memo: memo,
      iconName: iconName,
      colorValue: colorValue,
      childId: selectedChildId.value,
      startAlarm: startAlarm,
      startAlarmMinutes: startAlarmMinutes,
      endAlarm: endAlarm,
      endAlarmMinutes: endAlarmMinutes,
    );

    box.add(newSchedule); // Hive에 저장되면서 key가 생성됨
    await AlarmService.registerScheduleAlarms(newSchedule); // ✅ key 생성 후 알람 등록
    schedules.assignAll(box.values.toList());
    schedules.value = List.from(schedules);
    refreshUI();
    update();
  }

  void deleteSchedule(Schedule schedule) {
    AlarmService.cancelScheduleAlarms(schedule); // ✅ 추가
    schedule.delete();
    schedules.remove(schedule);
    schedules.refresh();
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
      refreshUI();
    });
  }

  bool hasOverlap(
    int day,
    DateTime start,
    DateTime end, {
    Schedule? excludeSelf,
  }) {
    return currentSchedules.any((s) {
      // ✅ currentSchedules로 변경
      if (s == excludeSelf) return false;
      if (s.dayOfWeek != day) return false;
      return start.isBefore(s.endTime) && end.isAfter(s.startTime);
    });
  }
}
