import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
// [주의] 아래 경로는 실제 파일 위치와 정확히 일치해야 합니다!
import 'data/schedule.dart';
import 'modules/home/home_view.dart';
import 'modules/home/home_controller.dart';

class AppColors {
  static const Color mainPurple = Color(0xFFC09FF8); // 메인 보라색 (이미지 레퍼런스)
  static const Color lightPurple = Color(0xFFE5D9F9); // 연한 보라 (배경용)
  static const Color darkPurple = Color(0xFF9F75E3); // 진한 보라 (그림자/강조용)
  static const Color white = Colors.white;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleAdapter());
  await Hive.openBox<Schedule>('schedules');

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timeline App',
      home: HomeView(),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightPurple, // 전체 배경을 연한 보라로
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightPurple,
          foregroundColor: AppColors.darkPurple, // 앱바 글씨/아이콘은 진한 보라
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.mainPurple,
          foregroundColor: AppColors.white,
        ),
      ),
    ),
  );
}
