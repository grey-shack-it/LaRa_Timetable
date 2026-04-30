import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../data/schedule.dart';

class AddScheduleDialog {
  static const Map<String, String> academyImages = {
    '국어': 'ic_korean.png',
    '영어': 'ic_english.png',
    '수학': 'ic_math.png',
    '미술': 'ic_art.png',
    '태권도': 'ic_taekwondo.png',
    '피아노': 'ic_piano.png',
    '독서': 'ic_read.png',
    '과학': 'ic_science.png',
    '학교': 'ic_school.png',
  };

  static const List<Color> pastelColors = [
    Color(0xFFC09FF8),
    Color(0xFFFFF59D),
    Color(0xFFFFCCBC),
    Color(0xFFFFAB91),
    Color(0xFFA5D6A7),
    Color(0xFF90CAF9),
  ];

  static const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

  static void show(BuildContext context, HomeController controller) {
    final titleController = TextEditingController();
    final now = DateTime.now();
    final startTime = DateTime(2024, 1, 1, now.hour, 0).obs;
    final endTime = DateTime(2024, 1, 1, now.hour + 1, 0).obs;
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
                                  final itemHeight = 75.0;
                                  final targetScroll =
                                      (row * itemHeight) - 37.5;
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
                                  child: _buildAcademyIcon(name, size: 55),
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
                      onTap: () => _showPicker(
                        startTime.value,
                        (d) => startTime.value = d,
                      ),
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
                      onTap: () => _showAlarmMinutePicker(startAlarmMinutes),
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
                      onTap: () =>
                          _showPicker(endTime.value, (d) => endTime.value = d),
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
                      onTap: () => _showAlarmMinutePicker(endAlarmMinutes),
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
                  String title = titleController.text.trim();

                  List<int> overlappingDays = selectedDays.where((day) {
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
              const SizedBox(height: 20),
            ],
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

  static void _showPicker(DateTime current, Function(DateTime) onSelected) {
    final tempTime = current.obs;
    Get.bottomSheet(
      Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text(
              '시간 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.darkPurple,
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: current,
                use24hFormat: true,
                minuteInterval: 5,
                onDateTimeChanged: (d) => tempTime.value = d,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onSelected(tempTime.value);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainPurple,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAlarmMinutePicker(RxInt targetMinutes) {
    final List<int> minuteOptions = [
      5,
      10,
      15,
      20,
      25,
      30,
      35,
      40,
      45,
      50,
      55,
      60,
    ];
    final initialIndex = minuteOptions
        .indexOf(targetMinutes.value)
        .clamp(0, minuteOptions.length - 1);
    final fixedController = FixedExtentScrollController(
      initialItem: initialIndex,
    );

    Get.bottomSheet(
      Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text(
              '알림 시간 설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.darkPurple,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: CupertinoPicker(
                scrollController: fixedController,
                itemExtent: 44,
                onSelectedItemChanged: (index) {
                  targetMinutes.value = minuteOptions[index];
                },
                children: minuteOptions
                    .map(
                      (m) => Center(
                        child: Text(
                          '$m분 전',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainPurple,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAcademyIcon(String name, {required double size}) {
    final fileName = academyImages[name];
    if (fileName == null) return const SizedBox.shrink();
    return Image.asset(
      'assets/icons/$fileName',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
