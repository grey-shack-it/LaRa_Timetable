import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../data/schedule.dart';
import '../../services/alarm_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 추가
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; // ✅ rootBundle
import 'package:my_timeline_app/constants/app_colors.dart';
import '../../services/image_save_service.dart';
import 'widgets/profile_tab_bar.dart';
import 'widgets/profile_manage_sheet.dart';
import 'widgets/schedule_block.dart';
import 'widgets/add_schedule_dialog.dart';
import 'widgets/edit_schedule_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  static const String _adUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // 광고 테스트 ID
  // 실제 배포 ID : ca-app-pub-8035187743335742/8495628808
  final ScreenshotController screenshotController = ScreenshotController();

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
        leading: IconButton(
          icon: const Icon(Icons.image, color: AppColors.darkPurple),
          onPressed: () =>
              ImageSaveService.saveTimeTable(screenshotController, controller),
        ),
        title: Obx(() {
          final title = controller.isOverlapView.value
              ? '아이들 시간표'
              : '${controller.getProfileName(controller.selectedChildId.value)}의 시간표';
          return Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.darkPurple,
            ),
          );
        }),
        centerTitle: true,
        backgroundColor: AppColors.lightPurple,
        elevation: 0,
        actions: [
          // ✅ 프로필 편집 아이콘
          IconButton(
            icon: const Icon(Icons.people, color: AppColors.darkPurple),
            onPressed: () => ProfileManageSheet.show(context, controller),
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
                  ProfileTabBar(controller: controller),
                  Expanded(
                    child: Screenshot(
                      controller: screenshotController,
                      child: Column(
                        children: [
                          // 1. 고정된 요일 헤더 영역
                          Row(
                            children: [
                              const SizedBox(width: 45), // 시간축 너비만큼 띄우기
                              ...List.generate(
                                7,
                                (index) => Expanded(
                                  child: _buildDayHeader(
                                    weekDays[index],
                                    index + 1,
                                  ),
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
                                                  color: AppColors.gridLine
                                                      .withValues(alpha: 0.8),
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
                                                color: AppColors.gridLine
                                                    .withValues(alpha: 0.8),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (dropContext) {
                                              return DragTarget<Schedule>(
                                                onWillAcceptWithDetails:
                                                    (details) => true,
                                                onAcceptWithDetails: (details) {
                                                  final RenderBox box =
                                                      dropContext
                                                              .findRenderObject()
                                                          as RenderBox;
                                                  final Offset localOffset = box
                                                      .globalToLocal(
                                                        details.offset,
                                                      );

                                                  // 🎯 좌표 보정: 드롭된 위치에 현재 시작 시간(start)을 더해줘야 정확한 시간이 계산됨
                                                  double adjustedY =
                                                      localOffset.dy +
                                                      (start * 60.0);
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
                                                        height:
                                                            totalHours * 60.0,
                                                        child: Stack(
                                                          children: [
                                                            _buildGridLines(
                                                              totalHours,
                                                            ),
                                                            // 해당 요일 일정만 표시 (좌표는 start 시간에 맞춰 - 처리)
                                                            ...controller
                                                                .displaySchedules
                                                                .where(
                                                                  (s) =>
                                                                      s.dayOfWeek ==
                                                                      dayNum,
                                                                )
                                                                .map(
                                                                  (
                                                                    s,
                                                                  ) => ScheduleBlock(
                                                                    controller:
                                                                        controller,
                                                                    schedule: s,
                                                                    startHour:
                                                                        start,
                                                                    onTap: () =>
                                                                        EditScheduleDialog.showEditOrDelete(
                                                                          context,
                                                                          controller,
                                                                          s,
                                                                        ),
                                                                  ),
                                                                ),
                                                            if (dayNum ==
                                                                DateTime.now()
                                                                    .weekday)
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
        onPressed: () => AddScheduleDialog.show(context, controller),
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

  static const List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
}
