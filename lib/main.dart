import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/schedule.dart';
import 'modules/home/home_view.dart';
// ignore: unused_import
import 'modules/home/home_controller.dart';
import 'services/alarm_service.dart'; // ✅ 추가
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 추가
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_timeline_app/constants/app_colors.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleAdapter());
  await Hive.openBox<Schedule>('schedules');
  await AlarmService.init(); // ✅ 추가
  await MobileAds.instance.initialize(); // ✅ 추가

  FlutterNativeSplash.remove();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '라라 시간표',
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
