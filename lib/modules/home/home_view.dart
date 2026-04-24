import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../data/schedule.dart';
import '../../services/alarm_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 추가

class AppColors {
  static const Color mainPurple = Color(0xFFC09FF8);
  static const Color lightPurple = Color(0xFFF1EBFF);
  static const Color darkPurple = Color(0xFF9468E6);
  static const Color gridLine = Color(0xFFBCA9E1);
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  static const String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

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
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('배너 광고 로드 실패: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

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
        actions: [
          // ✅ 프로필 편집 아이콘
          IconButton(
            icon: const Icon(Icons.people, color: AppColors.darkPurple),
            onPressed: () => _showProfileEditSheet(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  // ✅ 프로필 선택 영역
                  Obx(
                    () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...controller.profiles.map((profile) {
                            final isSelected =
                                controller.selectedChildId.value == profile.id;

                            return GestureDetector(
                              onTap: () {
                                controller.isOverlapView.value =
                                    false; // 한눈에 모드 자동 해제
                                controller.selectedChildId.value = profile.id;
                                controller.refreshUI();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.mainPurple
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.darkPurple.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  profile.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkPurple,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          // ✅ 겹쳐보기 버튼
                          Obx(
                            () => GestureDetector(
                              onTap: () {
                                controller.isOverlapView.value =
                                    !controller.isOverlapView.value;
                                controller.refreshUI();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.isOverlapView.value
                                      ? AppColors.darkPurple
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.darkPurple.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_alt,
                                      size: 16,
                                      color: controller.isOverlapView.value
                                          ? Colors.white
                                          : AppColors.darkPurple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '한눈에',
                                      style: TextStyle(
                                        color: controller.isOverlapView.value
                                            ? Colors.white
                                            : AppColors.darkPurple,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        print(
                          "🔥 실시간 렌더링 중: 일정 개수 ${controller.currentSchedules.length}",
                        );
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
                                        onWillAcceptWithDetails: (details) =>
                                            true,
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
                                        builder:
                                            (
                                              context,
                                              candidateData,
                                              rejectedData,
                                            ) {
                                              return SizedBox(
                                                height: totalHours * 60.0,
                                                child: Stack(
                                                  children: [
                                                    _buildGridLines(totalHours),
                                                    // 해당 요일 일정만 표시 (좌표는 start 시간에 맞춰 - 처리)
                                                    ...controller
                                                        .displaySchedules
                                                        .where(
                                                          (s) =>
                                                              s.dayOfWeek ==
                                                              dayNum,
                                                        )
                                                        .map(
                                                          (s) =>
                                                              _buildDraggableBlock(
                                                                context,
                                                                controller,
                                                                s,
                                                                start,
                                                              ),
                                                        ),
                                                    if (dayNum ==
                                                        DateTime.now().weekday)
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
          ),
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
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
          child: Opacity(
            opacity: 0.85,
            child: SizedBox(
              width: 44, // 블록 너비 (left:2, right:2 여백 감안)
              height: blockHeight,
              child: _buildBlockDesign(schedule, blockHeight),
            ),
          ),
        ),
        childWhenDragging: Obx(() {
          final isOverlap = controller.isOverlapView.value;
          final hasConflict = controller.isOverlappingWithOthers(schedule);
          return Opacity(
            opacity: isOverlap && hasConflict ? 0.55 : 0.3,
            child: _buildBlockDesign(schedule, blockHeight),
          );
        }),
        child: GestureDetector(
          onTap: () => _showEditOrDeleteDialog(context, controller, schedule),
          child: Obx(() {
            final isOverlap = controller.isOverlapView.value;
            final hasConflict = controller.isOverlappingWithOthers(schedule);
            return Opacity(
              opacity: isOverlap && hasConflict ? 0.75 : 1.0,
              child: _buildBlockDesign(schedule, blockHeight),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBlockDesign(Schedule schedule, double height) {
    double iconSize = height < 50 ? 28.0 : (height < 70 ? 40.0 : 52.0);
    final controller = Get.find<HomeController>();

    return Obx(() {
      final isOverlap = controller.isOverlapView.value;
      final profileColor = controller.getProfileColor(schedule.childId);
      final profileName = controller.getProfileName(schedule.childId);

      return Container(
        decoration: BoxDecoration(
          color: Color(schedule.colorValue),
          borderRadius: BorderRadius.circular(12),
          // ✅ 겹쳐보기일 때 아이별 테두리 색상 표시
          border: isOverlap && controller.isOverlappingWithOthers(schedule)
              ? Border.all(color: AppColors.darkPurple, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPurple.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 기존 아이콘 + 제목
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (schedule.iconName != null)
                  Flexible(
                    child: _buildAcademyIcon(
                      schedule.iconName!,
                      size: iconSize,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    schedule.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
              ],
            ),
            // ✅ 겹쳐보기일 때만 이름 뱃지 표시
            if (isOverlap)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: profileColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    profileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
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

  void _showAlarmMinutePicker(RxInt targetMinutes) {
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
    var selectedColor = pastelColors[0].obs;
    final startAlarm = false.obs;
    final startAlarmMinutes = 10.obs;
    final endAlarm = false.obs;
    final endAlarmMinutes = 10.obs;
    final List<String> iconKeys = academyImages.keys.toList();
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
              //아이콘 선택 영역
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
                          thickness: WidgetStateProperty.all(
                            6,
                          ), // 두께 (기본값 약 3~4)
                          radius: const Radius.circular(10), // 모서리 둥글기
                          thumbColor: WidgetStateProperty.all(
                            AppColors.mainPurple,
                          ), // 색상도 보라로 맞춤
                        ),
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true, // 항상 스크롤바 표시
                        child: Obx(
                          () => GridView.count(
                            controller: scrollController,
                            crossAxisCount: 4, // 한 행에 4개 고정
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
                                  final itemHeight = 75.0; // 셀 높이
                                  final targetScroll =
                                      (row * itemHeight) -
                                      37.5; // 선택 행이 중앙에 오도록
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
                                            BoxShadow(
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

              // ✅ 종료 시간 + 알람 행
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
                                startAlarm: startAlarm.value,
                                startAlarmMinutes: startAlarmMinutes.value,
                                endAlarm: endAlarm.value,
                                endAlarmMinutes: endAlarmMinutes.value,
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

  void _showProfileEditSheet(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      Obx(
        () => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '아이 프로필 관리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(height: 16),
              // 프로필 목록
              ...controller.profiles.map((profile) {
                final nameController = TextEditingController(
                  text: profile.name,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.child_care, color: AppColors.mainPurple),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (val) =>
                              controller.updateProfile(profile.id, val),
                          onEditingComplete: () {
                            controller.updateProfile(
                              profile.id,
                              nameController.text,
                            );
                            FocusScope.of(Get.context!).unfocus();
                          },
                        ),
                      ),
                      // ✅ 확인 버튼 추가
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: AppColors.mainPurple,
                        ),
                        onPressed: () {
                          controller.updateProfile(
                            profile.id,
                            nameController.text.trim(),
                          );
                          FocusScope.of(Get.context!).unfocus();
                        },
                      ),
                      // 삭제 버튼
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: controller.profiles.length > 1
                              ? Colors.redAccent
                              : Colors.grey,
                        ),
                        onPressed: controller.profiles.length > 1
                            ? () => _confirmDeleteProfile(
                                controller,
                                profile.id,
                                profile.name,
                              )
                            : null,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              // 아이 추가 버튼
              ElevatedButton.icon(
                onPressed: () => _showAddProfileDialog(controller),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '아이 추가',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainPurple,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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

  void _showAddProfileDialog(HomeController controller) {
    final nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('아이 추가'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: '이름을 입력하세요'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.addProfile(nameController.text.trim());
                Get.back();
              }
            },
            child: const Text(
              '추가',
              style: TextStyle(color: AppColors.mainPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile(
    HomeController controller,
    String id,
    String name,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('프로필 삭제'),
        content: Text('[$name]의 프로필과 모든 일정을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              controller.deleteProfile(id);
              Get.back();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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
    final startAlarm = schedule.startAlarm.obs;
    final startAlarmMinutes = schedule.startAlarmMinutes.obs;
    final endAlarm = schedule.endAlarm.obs;
    final endAlarmMinutes = schedule.endAlarmMinutes.obs;
    final List<String> iconKeys = academyImages.keys.toList();
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
              // 아이콘 선택 영역
              Builder(
                builder: (context) {
                  final scrollController = ScrollController();
                  // 선택된 아이콘의 행 번호 계산 후 자동 스크롤
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!scrollController.hasClients) return; // 안전 체크
                    final iconKeys = academyImages.keys.toList();
                    final selectedIndex = iconKeys.indexOf(selectedIcon.value);
                    if (selectedIndex >= 0) {
                      final row = (selectedIndex ~/ 4);
                      final itemHeight =
                          75.0; // GridView 셀 높이 (crossAxisCount:4 기준)
                      final scrollTo = (row * itemHeight).clamp(
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
                          thickness: WidgetStateProperty.all(
                            6,
                          ), // 두께 (기본값 약 3~4)
                          radius: const Radius.circular(10), // 모서리 둥글기
                          thumbColor: WidgetStateProperty.all(
                            AppColors.mainPurple,
                          ), // 색상도 보라로 맞춤
                        ),
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true, // 항상 스크롤바 표시
                        child: Obx(
                          () => GridView.count(
                            controller: scrollController,
                            crossAxisCount: 4, // 한 행에 4개 고정
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
                                  final itemHeight = 75.0; // 셀 높이
                                  final targetScroll =
                                      (row * itemHeight) -
                                      37.5; // 선택 행이 중앙에 오도록
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
                                            BoxShadow(
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

              const SizedBox(height: 20),
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

              // ✅ 종료 시간 + 알람 행
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
              ElevatedButton(
                onPressed: () {
                  schedule.title = titleController.text;
                  schedule.startTime = startTime.value;
                  schedule.endTime = endTime.value;
                  schedule.dayOfWeek = selectedDay.value;
                  schedule.iconName = selectedIcon.value;
                  schedule.colorValue = selectedColor.value.value;
                  schedule.startAlarm = startAlarm.value; // ✅ 추가
                  schedule.startAlarmMinutes = startAlarmMinutes.value; // ✅ 추가
                  schedule.endAlarm = endAlarm.value; // ✅ 추가
                  schedule.endAlarmMinutes = endAlarmMinutes.value; // ✅ 추가
                  schedule.save().then((_) {
                    AlarmService.registerScheduleAlarms(schedule); // ✅ 추가
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
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
}
