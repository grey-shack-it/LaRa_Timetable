import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../data/schedule.dart';
import '../../../services/alarm_service.dart';
import 'schedule_dialog_helpers.dart'; // ✅ 공통 헬퍼 import

class EditScheduleDialog {
  static void showEditOrDelete(
    BuildContext context,
    HomeController controller,
    Schedule schedule,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(schedule.title),
        content: const Text('이 일정을 어떻게 할까요?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDelete(controller, schedule);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showEditDialog(context, controller, schedule);
            },
            child: const Text(
              '수정',
              style: TextStyle(color: AppColors.darkPurple),
            ),
          ),
        ],
      ),
    );
  }

  static void _confirmDelete(HomeController controller, Schedule schedule) {
    Get.dialog(
      AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('[${schedule.title}] 일정을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              controller.deleteSchedule(schedule);
              Get.back();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  static void _showEditDialog(
    BuildContext context,
    HomeController controller,
    Schedule schedule,
  ) {
    final titleController = TextEditingController(text: schedule.title);
    final startTime = schedule.startTime.obs;
    final endTime = schedule.endTime.obs;
    final selectedIcon = (schedule.iconName ?? '국어').obs;
    final selectedColor = Color(schedule.colorValue).obs;
    final selectedDay = schedule.dayOfWeek.obs; // ✅ 요일 상태
    final startAlarm = schedule.startAlarm.obs;
    final startAlarmMinutes = schedule.startAlarmMinutes.obs;
    final endAlarm = schedule.endAlarm.obs;
    final endAlarmMinutes = schedule.endAlarmMinutes.obs;

    final iconKeys = academyImages.keys.toList();

    Get.bottomSheet(
      isScrollControlled: true,
      SingleChildScrollView(
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
                '일정 수정',
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!scrollController.hasClients) return;
                    final selectedIndex = iconKeys.indexOf(selectedIcon.value);
                    if (selectedIndex >= 0) {
                      final row = (selectedIndex ~/ 4);
                      final scrollTo = (row * 75.0).clamp(
                        0.0,
                        scrollController.position.maxScrollExtent,
                      );
                      scrollController.animateTo(
                        scrollTo,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

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
                                      scrollController.position.maxScrollExtent,
                                    ),
                                    duration: const Duration(milliseconds: 300),
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

              // ✅ 요일 선택 (기존에 누락됐던 UI 추가)
              Obx(
                () => Wrap(
                  spacing: 7,
                  children: List.generate(
                    7,
                    (i) => ChoiceChip(
                      label: Text(days[i]),
                      selected: selectedDay.value == i + 1,
                      selectedColor: AppColors.mainPurple,
                      onSelected: (val) {
                        if (val) selectedDay.value = i + 1;
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
                      onTap: () => showScheduleTimePicker(
                        startTime.value,
                        (d) => startTime.value = d,
                      ), // ✅ 헬퍼 사용
                      child: Row(
                        children: [
                          const Text('시작 시간  ', style: TextStyle(fontSize: 16)),
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
                          const Text('종료 시간  ', style: TextStyle(fontSize: 16)),
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

              // 수정 완료 버튼
              ElevatedButton(
                onPressed: () {
                  schedule.title = titleController.text;
                  schedule.startTime = startTime.value;
                  schedule.endTime = endTime.value;
                  schedule.dayOfWeek = selectedDay.value; // ✅ 요일 저장
                  schedule.iconName = selectedIcon.value;
                  schedule.colorValue = selectedColor.value.value;
                  schedule.startAlarm = startAlarm.value;
                  schedule.startAlarmMinutes = startAlarmMinutes.value;
                  schedule.endAlarm = endAlarm.value;
                  schedule.endAlarmMinutes = endAlarmMinutes.value;
                  schedule.save().then((_) {
                    AlarmService.registerScheduleAlarms(schedule);
                    controller.refreshUI();
                  });
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
                  '수정 완료',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
