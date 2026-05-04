import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';

// ✅ 공통 상수
const Map<String, String> academyImages = {
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

const List<Color> pastelColors = [
  Color(0xFFC09FF8),
  Color(0xFFFFF59D),
  Color(0xFFFFCCBC),
  Color(0xFFFFAB91),
  Color(0xFFA5D6A7),
  Color(0xFF90CAF9),
];

const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

// ✅ 공통 메서드

Widget buildAcademyIcon(String name, {required double size}) {
  final fileName = academyImages[name];
  if (fileName == null) return const SizedBox.shrink();
  return Image.asset(
    'assets/icons/$fileName',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
}

void showScheduleTimePicker(DateTime current, Function(DateTime) onSelected) {
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

void showAlarmMinutePicker(RxInt targetMinutes) {
  const List<int> minuteOptions = [
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
