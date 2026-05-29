import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';
import 'schedule_dialog_helpers.dart'; // ✅ 공통 헬퍼 import

class AddScheduleDialog {
  static void show(BuildContext context, HomeController controller) {
    final titleController = TextEditingController();
    final now = DateTime.now();
    final roundedMinute = ((now.minute / 10).ceil() * 10);
    final startHour = roundedMinute == 60 ? now.hour + 1 : now.hour;
    final startMinute = roundedMinute == 60 ? 0 : roundedMinute;
    final startTime = DateTime(2024, 1, 1, startHour, startMinute).obs;
    final endTime = DateTime(
      2024,
      1,
      1,
      startHour + 1,
      startMinute,
    ).obs; // ✅ now.hour+1 대신 startHour+1
    final selectedIcon = academyImages.keys.first.obs;
    final selectedColor = pastelColors.first.obs;
    final selectedDays = <int>{_currentDayOfWeek()}.obs;
    final startAlarm = false.obs;
    final startAlarmMinutes = 10.obs;
    final endAlarm = false.obs;
    final endAlarmMinutes = 10.obs;

    final iconKeys = academyImages.keys.toList();

    Get.bottomSheet(
      isScrollControlled: true,
      SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '일정 추가',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkPurple,
                  ),
                ),
                const SizedBox(height: 16),

                // 제목 입력
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: '일정을 입력해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 아이콘 선택
                Builder(
                  builder: (context) {
                    final scrollController = ScrollController();
                    return Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            thumbVisibility: WidgetStateProperty.all(true),
                            thickness: WidgetStateProperty.all(6),
                            radius: const Radius.circular(10),
                            thumbColor: WidgetStateProperty.all(
                              AppColors.mainPurple,
                            ),
                          ),
                        ),
                        child: Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          child: Obx(
                            () => GridView.count(
                              controller: scrollController,
                              crossAxisCount: 4,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 10,
                                bottom: 10,
                                right: 16,
                              ),
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              children: iconKeys.map((name) {
                                final isSelected = selectedIcon.value == name;
                                return GestureDetector(
                                  onTap: () {
                                    selectedIcon.value = name;
                                    final index = iconKeys.indexOf(name);
                                    final row = (index ~/ 4);
                                    final targetScroll = (row * 75.0) - 37.5;
                                    scrollController.animateTo(
                                      targetScroll.clamp(
                                        0.0,
                                        scrollController
                                            .position
                                            .maxScrollExtent,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.mainPurple
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: isSelected
                                          ? [
                                              const BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: buildAcademyIcon(
                                      name,
                                      size: 55,
                                    ), // ✅ 헬퍼 사용
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 색상 선택
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: pastelColors.map((color) {
                      return GestureDetector(
                        onTap: () => selectedColor.value = color,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor.value == color
                                  ? Colors.grey[400]!
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // 요일 선택
                Obx(
                  () => Wrap(
                    spacing: 7,
                    children: List.generate(
                      7,
                      (i) => FilterChip(
                        label: Text(days[i]),
                        selected: selectedDays.contains(i + 1),
                        selectedColor: AppColors.mainPurple,
                        onSelected: (val) {
                          if (val) {
                            selectedDays.add(i + 1);
                          } else {
                            selectedDays.remove(i + 1);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 시작 시간 + 알람
                Obx(
                  () => Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            showScheduleTimePicker(startTime.value, (d) {
                              startTime.value = d;
                              // ✅ 종료 시간도 시작 시간 + 1시간으로 자동 업데이트
                              endTime.value = d.add(const Duration(hours: 1));
                            }),
                        child: Row(
                          children: [
                            const Text(
                              '시작 시간  ',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 40),
                            Text(
                              '${startTime.value.hour}:${startTime.value.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            showAlarmMinutePicker(startAlarmMinutes), // ✅ 헬퍼 사용
                        child: Text(
                          '${startAlarmMinutes.value}분전 알림',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Checkbox(
                        value: startAlarm.value,
                        activeColor: AppColors.mainPurple,
                        onChanged: (val) => startAlarm.value = val ?? false,
                      ),
                    ],
                  ),
                ),

                // 종료 시간 + 알람
                Obx(
                  () => Row(
                    children: [
                      GestureDetector(
                        onTap: () => showScheduleTimePicker(
                          endTime.value,
                          (d) => endTime.value = d,
                        ), // ✅ 헬퍼 사용
                        child: Row(
                          children: [
                            const Text(
                              '종료 시간  ',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 40),
                            Text(
                              '${endTime.value.hour}:${endTime.value.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            showAlarmMinutePicker(endAlarmMinutes), // ✅ 헬퍼 사용
                        child: Text(
                          '${endAlarmMinutes.value}분전 알림',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Checkbox(
                        value: endAlarm.value,
                        activeColor: AppColors.mainPurple,
                        onChanged: (val) => endAlarm.value = val ?? false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 등록 버튼
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();

                    final overlappingDays = selectedDays.where((day) {
                      return controller.hasOverlap(
                        day,
                        startTime.value,
                        endTime.value,
                      );
                    }).toList();

                    if (overlappingDays.isNotEmpty) {
                      final dayNames = overlappingDays
                          .map((d) => days[d - 1])
                          .join(', ');
                      Get.dialog(
                        AlertDialog(
                          title: const Text('일정 겹침 안내'),
                          content: Text(
                            '[$dayNames] 요일에 이미 같은 시간대의 일정이 있어요.\n그래도 등록할까요?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('다시 입력'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                _doAddSchedule(
                                  controller,
                                  title,
                                  startTime.value,
                                  endTime.value,
                                  selectedDays.toList(),
                                  selectedIcon.value,
                                  selectedColor.value,
                                  startAlarm: startAlarm.value,
                                  startAlarmMinutes: startAlarmMinutes.value,
                                  endAlarm: endAlarm.value,
                                  endAlarmMinutes: endAlarmMinutes.value,
                                );
                                Get.back();
                              },
                              child: const Text(
                                '그래도 등록',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    _doAddSchedule(
                      controller,
                      title,
                      startTime.value,
                      endTime.value,
                      selectedDays.toList(),
                      selectedIcon.value,
                      selectedColor.value,
                      startAlarm: startAlarm.value,
                      startAlarmMinutes: startAlarmMinutes.value,
                      endAlarm: endAlarm.value,
                      endAlarmMinutes: endAlarmMinutes.value,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainPurple,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '일정 등록',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _doAddSchedule(
    HomeController controller,
    String title,
    DateTime startTime,
    DateTime endTime,
    List<int> selectedDays,
    String selectedIcon,
    Color selectedColor, {
    bool startAlarm = false,
    int startAlarmMinutes = 10,
    bool endAlarm = false,
    int endAlarmMinutes = 10,
  }) {
    for (var day in selectedDays) {
      controller.addSchedule(
        title,
        startTime,
        endTime,
        day,
        '',
        selectedIcon,
        selectedColor.value,
        startAlarm: startAlarm,
        startAlarmMinutes: startAlarmMinutes,
        endAlarm: endAlarm,
        endAlarmMinutes: endAlarmMinutes,
      );
    }
  }

  static int _currentDayOfWeek() {
    final weekday = DateTime.now().weekday;
    return weekday <= 7 ? weekday : 1;
  }
}
