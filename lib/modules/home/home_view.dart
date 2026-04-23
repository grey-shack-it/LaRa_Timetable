import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../data/schedule.dart';

class AppColors {
  static const Color mainPurple = Color(0xFFC09FF8);
  static const Color lightPurple = Color(0xFFF1EBFF);
  static const Color darkPurple = Color(0xFF9468E6);
  static const Color gridLine = Color(0xFFBCA9E1);
}

class HomeView extends StatelessWidget {
  // 다시 StatelessWidget으로!
  const HomeView({super.key});

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
    Color(0xFFC09FF8), // 보라 (기존)
    Color(0xFFFFF59D), // 노랑
    Color(0xFFFFCCBC), // 주황
    Color(0xFFFFAB91), // 빨강
    Color(0xFFA5D6A7), // 초록
    Color(0xFF90CAF9), // 파랑
  ];

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(
      HomeController(),
      permanent: true,
    );
    final List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];

    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        title: const Text(
          '아이들 일정 관리',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.darkPurple,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          // 🎯 전체를 Column으로 묶어 상단 요일 고정
          children: [
            // 1. 고정된 요일 헤더 영역
            Row(
              children: [
                const SizedBox(width: 45), // 시간축 너비만큼 띄우기
                ...List.generate(
                  7,
                  (index) => Expanded(
                    child: _buildDayHeader(weekDays[index], index + 1),
                  ),
                ),
              ],
            ),

            // 2. 스크롤되는 시간표 그리드 영역
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  // 확인용 로그 (디버그 콘솔에 찍힙니다)
                  print("🔥 실시간 렌더링 중: 일정 개수 ${controller.schedules.length}");
                  // 동적으로 계산된 시작/종료 시간 사용
                  int start = controller.startHour.value;
                  int end = controller.endHour.value;
                  int totalHours = end - start + 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽 시간축
                      Container(
                        width: 45,
                        child: Column(
                          children: List.generate(
                            totalHours,
                            (i) => Container(
                              // 🎯 SizedBox를 Container로 변경
                              height: 60,
                              decoration: BoxDecoration(
                                // 🎯 테두리 선 추가
                                border: Border(
                                  bottom: BorderSide(
                                    // 일정표 안의 선과 색상/두께를 맞추는 게 중요합니다!
                                    color: AppColors.gridLine.withValues(
                                      alpha: 0.8,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${start + i}시',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.darkPurple,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 요일별 그리드
                      ...List.generate(7, (index) {
                        int dayNum = index + 1;
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.gridLine.withValues(
                                    alpha: 0.8,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Builder(
                              builder: (dropContext) {
                                return DragTarget<Schedule>(
                                  onWillAcceptWithDetails: (details) => true,
                                  onAcceptWithDetails: (details) {
                                    final RenderBox box =
                                        dropContext.findRenderObject()
                                            as RenderBox;
                                    final Offset localOffset = box
                                        .globalToLocal(details.offset);

                                    // 🎯 좌표 보정: 드롭된 위치에 현재 시작 시간(start)을 더해줘야 정확한 시간이 계산됨
                                    double adjustedY =
                                        localOffset.dy + (start * 60.0);
                                    controller.updateScheduleTime(
                                      details.data,
                                      dayNum,
                                      adjustedY,
                                    );
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return SizedBox(
                                      height: totalHours * 60.0,
                                      child: Stack(
                                        children: [
                                          _buildGridLines(totalHours),
                                          // 해당 요일 일정만 표시 (좌표는 start 시간에 맞춰 - 처리)
                                          ...controller.schedules
                                              .where(
                                                (s) => s.dayOfWeek == dayNum,
                                              )
                                              .map(
                                                (s) => _buildDraggableBlock(
                                                  context,
                                                  controller,
                                                  s,
                                                  start,
                                                ),
                                              ),
                                          if (dayNum == DateTime.now().weekday)
                                            _buildCurrentTimeLine(
                                              controller,
                                              start,
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainPurple,
        onPressed: () => _showAddDialog(context, controller),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- 기존 위젯 및 팝업 로직 (수정 사항 반영) ---

  Widget _buildDayHeader(String label, int dayNum) {
    bool isToday = dayNum == DateTime.now().weekday;
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.mainPurple
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isToday ? Colors.white : AppColors.darkPurple,
        ),
      ),
    );
  }

  Widget _buildGridLines(int hours) {
    return Column(
      children: List.generate(
        hours,
        (i) => Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.gridLine.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeLine(HomeController controller, int startHour) {
    return Obx(() {
      final now = controller.now.value;
      // 현재 시간이 표시 범위 내에 있을 때만 라인 표시
      if (now.hour < startHour || now.hour > controller.endHour.value) {
        return const SizedBox.shrink();
      }

      final top = ((now.hour - startHour) * 60.0) + now.minute;
      return Positioned(
        top: top,
        left: 0,
        right: 0,
        child: Container(height: 2.5, color: Colors.deepPurple),
      );
    });
  }

  Widget _buildDraggableBlock(
    BuildContext context,
    HomeController controller,
    Schedule schedule,
    int startHour,
  ) {
    // 시작 시간(startHour)을 기준으로 Y좌표 결정
    final double top =
        ((schedule.startTime.hour - startHour) * 60.0) +
        schedule.startTime.minute;
    final durationMinutes = schedule.endTime
        .difference(schedule.startTime)
        .inMinutes;
    final double blockHeight = durationMinutes >= 30
        ? durationMinutes.toDouble()
        : 30.0;

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: blockHeight,
      child: Draggable<Schedule>(
        data: schedule,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 50,
            height: blockHeight,
            decoration: BoxDecoration(
              color: AppColors.mainPurple.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.touch_app, color: Colors.white, size: 20),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildBlockDesign(schedule, blockHeight),
        ),
        child: GestureDetector(
          onTap: () => _showEditOrDeleteDialog(context, controller, schedule),
          child: _buildBlockDesign(schedule, blockHeight),
        ),
      ),
    );
  }

  Widget _buildBlockDesign(Schedule schedule, double height) {
    double iconSize = height < 50 ? 28.0 : (height < 70 ? 40.0 : 52.0);
    return Container(
      decoration: BoxDecoration(
        color: Color(schedule.colorValue),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPurple.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (schedule.iconName != null)
            Flexible(
              child: _buildAcademyIcon(schedule.iconName!, size: iconSize),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                schedule.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 99, 98, 98),
                      offset: Offset(0.5, 0.5),
                      blurRadius: 3.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 기존 아이콘 및 다이얼로그 로직은 동일 (생략) ---
  Widget _buildAcademyIcon(String iconName, {double size = 24.0}) {
    final fileName = academyImages[iconName];
    return fileName != null
        ? Image.asset(
            'assets/icons/$fileName',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) =>
                Icon(Icons.school, size: size, color: Colors.white),
          )
        : Icon(Icons.school, size: size, color: Colors.white);
  }

  void _showPicker(DateTime initialTime, Function(DateTime) onChanged) {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                child: const Text('확인'),
                onPressed: () => Get.back(),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialTime,
                use24hFormat: true,
                minuteInterval: 10,
                onDateTimeChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, HomeController controller) {
    final titleController = TextEditingController();
    DateTime now = DateTime.now();
    DateTime initialStart = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      (now.minute ~/ 10) * 10,
    );
    var startTime = initialStart.obs;
    var endTime = initialStart.add(const Duration(minutes: 60)).obs;
    // 🎯 시작 시간이 변경될 때마다 실행될 마법의 코드
    ever(startTime, (DateTime newStart) {
      // 종료 시간을 시작 시간보다 1시간 뒤로 자동 설정
      endTime.value = newStart.add(const Duration(minutes: 60));
    });
    var selectedDays = <int>[DateTime.now().weekday].obs;
    var selectedIcon = '국어'.obs;
    var selectedColor = HomeView.pastelColors[0].obs;
    final List<String> iconKeys = HomeView.academyImages.keys.toList();
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '일정 추가',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '일정을 입력해주세요',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 150, // 👈 딱 이만큼만 높이를 쓰라고 강제로 못 박습니다.
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50], // 영역 구분을 위해 아주 연한 회색 배경
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  // 👈 복잡한 격자 계산 대신 단순 스크롤 사용
                  padding: const EdgeInsets.all(10),
                  child: Obx(
                    () => Wrap(
                      spacing: 20,
                      runSpacing: 1,
                      alignment: WrapAlignment.start,
                      children: iconKeys.map((name) {
                        // 👈 위에서 선언한 iconKeys 사용
                        final isSelected = selectedIcon.value == name;
                        return GestureDetector(
                          onTap: () => selectedIcon.value = name,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.mainPurple
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: _buildAcademyIcon(name, size: 65),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: pastelColors.map((color) {
                    return GestureDetector(
                      onTap: () => selectedColor.value = color,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          // 선택된 색상에만 검정색 테두리(두께 3)를 줘서 "선택됨" 표시
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
              Obx(
                () => Wrap(
                  spacing: 7,
                  children: List.generate(7, (i) {
                    int dNum = i + 1;
                    return FilterChip(
                      label: Text(
                        days[i],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      selected: selectedDays.contains(dNum),
                      selectedColor: AppColors.mainPurple,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          selectedDays.add(dNum);
                        } else if (selectedDays.length > 1) {
                          selectedDays.remove(dNum);
                        }
                      },
                    );
                  }),
                ),
              ),
              ListTile(
                title: const Text('시작 시간'),
                trailing: Obx(
                  () => Text(
                    '${startTime.value.hour}:${startTime.value.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () =>
                    _showPicker(startTime.value, (d) => startTime.value = d),
              ),
              ListTile(
                title: const Text('종료 시간'),
                trailing: Obx(
                  () => Text(
                    '${endTime.value.hour}:${endTime.value.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () =>
                    _showPicker(endTime.value, (d) => endTime.value = d),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String title = titleController.text.trim();
                  // 겹치는 요일이 있는지 확인
                  List<int> overlappingDays = selectedDays.where((day) {
                    return controller.hasOverlap(
                      day,
                      startTime.value,
                      endTime.value,
                    );
                  }).toList();
                  if (overlappingDays.isNotEmpty) {
                    // 겹치는 요일 이름 만들기 (예: "월, 수")
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
                            onPressed: () => Get.back(), // 다이얼로그만 닫기 (바텀시트는 유지)
                            child: const Text('다시 입력'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back(); // 다이얼로그 닫기
                              _doAddSchedule(
                                controller,
                                title,
                                startTime.value,
                                endTime.value,
                                selectedDays.toList(),
                                selectedIcon.value,
                                selectedColor.value,
                              );
                              Get.back(); // 바텀시트 닫기
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
                  );
                  Get.back();

                  // 2. 선택된 모든 요일에 대해 일정 추가
                  for (var day in selectedDays) {
                    controller.addSchedule(
                      title,
                      startTime.value,
                      endTime.value,
                      day,
                      "", // 메모
                      selectedIcon.value,
                      selectedColor.value.value, // 선택된 색상값 추가
                    );
                  }
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
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _doAddSchedule(
    HomeController controller,
    String title,
    DateTime startTime,
    DateTime endTime,
    List<int> selectedDays,
    String selectedIcon,
    Color selectedColor,
  ) {
    for (var day in selectedDays) {
      controller.addSchedule(
        title,
        startTime,
        endTime,
        day,
        '',
        selectedIcon,
        selectedColor.value,
      );
    }
  }

  void _showEditOrDeleteDialog(
    BuildContext context,
    HomeController controller,
    Schedule schedule,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(schedule.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              _showEditDialog(context, controller, schedule);
            },
            child: const Text('수정하기'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              controller.deleteSchedule(schedule);
              Get.back();
            },
            child: const Text('삭제하기'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    HomeController controller,
    Schedule schedule,
  ) {
    final titleController = TextEditingController(text: schedule.title);
    var startTime = schedule.startTime.obs;
    var endTime = schedule.endTime.obs;
    // 🎯 시작 시간이 변경될 때마다 실행될 마법의 코드
    ever(startTime, (DateTime newStart) {
      // 종료 시간을 시작 시간보다 1시간 뒤로 자동 설정
      endTime.value = newStart.add(const Duration(minutes: 60));
    });
    var selectedDay = schedule.dayOfWeek.obs;
    var selectedIcon = (schedule.iconName ?? '국어').obs;
    var selectedColor = (Color(schedule.colorValue)).obs;
    final List<String> iconKeys = HomeView.academyImages.keys.toList();
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '일정 수정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '일정을 입력해주세요',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 150, // 👈 딱 이만큼만 높이를 쓰라고 강제로 못 박습니다.
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50], // 영역 구분을 위해 아주 연한 회색 배경
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  // 👈 복잡한 격자 계산 대신 단순 스크롤 사용
                  padding: const EdgeInsets.all(10),
                  child: Obx(
                    () => Wrap(
                      spacing: 20,
                      runSpacing: 1,
                      alignment: WrapAlignment.start,
                      children: iconKeys.map((name) {
                        // 👈 위에서 선언한 iconKeys 사용
                        final isSelected = selectedIcon.value == name;
                        return GestureDetector(
                          onTap: () => selectedIcon.value = name,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.mainPurple
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: _buildAcademyIcon(name, size: 65),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: HomeView.pastelColors.map((color) {
                    return GestureDetector(
                      onTap: () => selectedColor.value = color,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            // 진한 회색 테두리 적용
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
              ListTile(
                title: const Text('시작 시간'),
                trailing: Obx(
                  () => Text(
                    '${startTime.value.hour}:${startTime.value.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () =>
                    _showPicker(startTime.value, (d) => startTime.value = d),
              ),
              ListTile(
                title: const Text('종료 시간'),
                trailing: Obx(
                  () => Text(
                    '${endTime.value.hour}:${endTime.value.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () =>
                    _showPicker(endTime.value, (d) => endTime.value = d),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  schedule.title = titleController.text;
                  schedule.startTime = startTime.value;
                  schedule.endTime = endTime.value;
                  schedule.dayOfWeek = selectedDay.value;
                  schedule.iconName = selectedIcon.value;
                  schedule.colorValue = selectedColor.value.value;
                  schedule.save().then((_) => controller.schedules.refresh());
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
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
}
