import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/schedule.dart';
import '../../data/child_profile.dart'; // ✅ 추가
import 'package:flutter/material.dart';
import '../../services/alarm_service.dart';

class HomeController extends GetxController {
  final RxList<Schedule> schedules = <Schedule>[].obs;
  var now = DateTime.now().obs;

  RxInt startHour = 7.obs;
  RxInt endHour = 21.obs;

  final RxList<ChildProfile> profiles = <ChildProfile>[].obs; // ✅ 초기값 제거
  final RxString selectedChildId = ''.obs;
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
      if (s == target) return false;
      if (s.childId == target.childId) return false;
      if (s.dayOfWeek != target.dayOfWeek) return false;
      return target.startTime.isBefore(s.endTime) &&
          target.endTime.isAfter(s.startTime);
    });
  }

  List<Schedule> get displaySchedules =>
      isOverlapView.value ? schedules.toList() : currentSchedules;

  List<Schedule> get currentSchedules =>
      schedules.where((s) => s.childId == selectedChildId.value).toList();

  @override
  void onInit() {
    super.onInit();
    loadProfiles(); // ✅ 프로필 먼저 로드
    loadSchedules();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      now.value = DateTime.now();
    });
  }

  // ✅ Hive에서 프로필 불러오기
  void loadProfiles() {
    final box = Hive.box<ChildProfile>('profiles');

    // 저장된 프로필이 없으면 기본 프로필 생성
    if (box.isEmpty) {
      final defaultProfile = ChildProfile(id: 'default', name: '첫째');
      box.add(defaultProfile);
    }

    profiles.assignAll(box.values.toList());
    selectedChildId.value = profiles.first.id;
  }

  // ✅ 프로필 추가 — Hive에 저장
  void addProfile(String name) {
    final box = Hive.box<ChildProfile>('profiles');
    final newProfile = ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    box.add(newProfile);
    profiles.assignAll(box.values.toList());
  }

  // ✅ 프로필 이름 수정 — Hive에 저장
  void updateProfile(String id, String newName) {
    final profile = profiles.firstWhereOrNull((p) => p.id == id);
    if (profile != null) {
      profile.name = newName;
      profile.save(); // ✅ HiveObject의 save() 사용
      profiles.refresh();
    }
  }

  // ✅ 프로필 삭제 — Hive에서도 삭제
  void deleteProfile(String id) {
    if (profiles.length <= 1) return;

    // 해당 아이 일정 삭제
    final toDelete = schedules.where((s) => s.childId == id).toList();
    for (var s in toDelete) {
      AlarmService.cancelScheduleAlarms(s);
      s.delete();
    }
    schedules.removeWhere((s) => s.childId == id);

    // 프로필 Hive에서 삭제
    final profile = profiles.firstWhereOrNull((p) => p.id == id);
    if (profile != null) {
      profile.delete(); // ✅ HiveObject의 delete() 사용
    }
    profiles.removeWhere((p) => p.id == id);

    if (selectedChildId.value == id) {
      selectedChildId.value = profiles.first.id;
    }
    refreshUI();
  }

  void refreshUI() {
    int min = 7;
    int max = 21;

    for (var s in displaySchedules) {
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

    box.add(newSchedule);
    await AlarmService.registerScheduleAlarms(newSchedule);
    schedules.assignAll(box.values.toList());
    schedules.value = List.from(schedules);
    refreshUI();
    update();
  }

  void deleteSchedule(Schedule schedule) {
    if (schedule.key != null) {
      AlarmService.cancelScheduleAlarms(schedule);
    }
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
      if (s == excludeSelf) return false;
      if (s.dayOfWeek != day) return false;
      return start.isBefore(s.endTime) && end.isAfter(s.startTime);
    });
  }
}
