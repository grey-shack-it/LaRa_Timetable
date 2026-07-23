import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_timeline_app/constants/app_colors.dart';
import 'widgets/profile_tab_bar.dart';
import 'widgets/schedule_block.dart';
import 'widgets/add_schedule_dialog.dart';
import 'widgets/edit_schedule_dialog.dart';
import 'widgets/time_grid.dart';
import 'package:flutter/foundation.dart';
import '../auth/login_view.dart';
import '../academy/academy_view.dart';
import '../../services/auth_service.dart';
import '../academy/academy_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  late final HomeController controller;

  static const String _adUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-8035187743335742/8495628808';

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController(), permanent: true);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('배너 광고 로드 실패: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // ✅ 배경색 변경 컬러피커 다이얼로그
  void _showBgColorPicker() {
    Color tempColor = controller.bgColor.value;
    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              '배경색 선택',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.darkPurple,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    // ✅ 색이 바뀌면 key도 바뀌어서 위젯이 새로 그려짐 → '기본색상' 눌렀을 때 화면에도 바로 반영됨
                    key: ValueKey(tempColor.value),
                    pickerColor: tempColor,
                    onColorChanged: (color) => tempColor = color,
                    enableAlpha: false,
                    labelTypes: const [],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkPurple),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          tempColor = AppColors.lightPurple; // ✅ 원래 기본 배경색
                        });
                      },
                      child: const Text(
                        '기본색상',
                        style: TextStyle(color: AppColors.darkPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('취소')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainPurple,
                ),
                onPressed: () {
                  controller.setBgColor(tempColor);
                  Get.back();
                },
                child: const Text('적용', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bg = controller.bgColor.value;
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          // 1. 왼쪽(leading)에 로그인 버튼(앱 아이콘) 배치
          leading: Center(
            // Center로 감싸서 좌측 패딩 정렬을 예쁘게 잡아줍니다.
            child: GestureDetector(
              onTap: () {
                if (AuthService.currentUser != null) {
                  Get.delete<AcademyController>(force: true);
                  Get.off(() => const AcademyView());
                } else {
                  Get.to(() => const LoginView());
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. 가운데 제목 (기존 유지)
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
          backgroundColor: bg,
          elevation: 0,

          // 3. 오른쪽(actions)에 배경색 변경 버튼 배치
          actions: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.palette, color: AppColors.darkPurple),
              onPressed: _showBgColorPicker,
            ),
            const SizedBox(width: 4), // 우측 여백 살짝 주기
          ],
        ),

        // ✅ 광고 배너를 bottomNavigationBar로 이동 — SafeArea로 네비게이션바 겹침 방지
        bottomNavigationBar: _isAdLoaded && _bannerAd != null
            ? SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 1, color: AppColors.gridLine),
                    SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ],
                ),
              )
            : null,

        body: SafeArea(
          child: Column(
            children: [
              ProfileTabBar(controller: controller),
              Expanded(
                child: Column(
                  children: [
                    // 요일 헤더
                    Row(
                      children: [
                        const SizedBox(width: 45),
                        ...List.generate(
                          7,
                          (index) => Expanded(
                            child: DayHeader(
                              label: ['월', '화', '수', '목', '금', '토', '일'][index],
                              dayNum: index + 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 시간표 그리드
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(() {
                          final _ = controller.selectedChildId.value;
                          final _ = controller.schedules.length;
                          int start = controller.startHour.value;
                          int end = controller.endHour.value;
                          int totalHours = end - start + 1;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 시간축
                              SizedBox(
                                width: 45,
                                child: Column(
                                  children: List.generate(
                                    totalHours,
                                    (i) => Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
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
                                          color: AppColors.gridLine.withValues(
                                            alpha: 0.8,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: GestureDetector(
                                      onLongPressStart: (details) {
                                        final touchY = details.localPosition.dy;
                                        final totalMinutes =
                                            (touchY + start * 60).toInt();
                                        final hour = (totalMinutes ~/ 60).clamp(
                                          0,
                                          23,
                                        );
                                        final minute =
                                            ((totalMinutes % 60) ~/ 30) * 30;

                                        final startTime = DateTime(
                                          2024,
                                          1,
                                          1,
                                          hour,
                                          minute,
                                        );
                                        final endTime = startTime.add(
                                          const Duration(hours: 1),
                                        );

                                        AddScheduleDialog.show(
                                          context,
                                          controller,
                                          initialDay: dayNum,
                                          initialStartTime: startTime,
                                          initialEndTime: endTime,
                                        );
                                      },
                                      child: SizedBox(
                                        height: totalHours * 60.0,
                                        child: Stack(
                                          children: [
                                            GridLines(hours: totalHours),
                                            ...controller.displaySchedules
                                                .where(
                                                  (s) => s.dayOfWeek == dayNum,
                                                )
                                                .map(
                                                  (s) => ScheduleBlock(
                                                    controller: controller,
                                                    schedule: s,
                                                    startHour: start,
                                                    onTap: () =>
                                                        EditScheduleDialog.showEditOrDelete(
                                                          context,
                                                          controller,
                                                          s,
                                                        ),
                                                  ),
                                                ),
                                            if (dayNum ==
                                                DateTime.now().weekday)
                                              CurrentTimeLine(
                                                controller: controller,
                                                startHour: start,
                                              ),
                                          ],
                                        ),
                                      ),
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
            ],
          ),
        ),

        // ✅ + 버튼은 패딩 없이 그냥 사용 (bottomNavigationBar가 알아서 위에 배치)
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.mainPurple,
          onPressed: () => AddScheduleDialog.show(context, controller),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }
}
