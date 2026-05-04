import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/schedule.dart';
import 'data/child_profile.dart'; // ✅ 추가
import 'modules/home/home_view.dart';
// ignore: unused_import
import 'modules/home/home_controller.dart';
import 'services/alarm_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_timeline_app/constants/app_colors.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(ChildProfileAdapter()); // ✅ 추가
  await Hive.openBox<Schedule>('schedules');
  await Hive.openBox<ChildProfile>('profiles'); // ✅ 추가

  await AlarmService.init();
  await MobileAds.instance.initialize();

  FlutterNativeSplash.remove();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '라라 시간표',
      home: HomeView(),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightPurple,
          foregroundColor: AppColors.darkPurple,
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
