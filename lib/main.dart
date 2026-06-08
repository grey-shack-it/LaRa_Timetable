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
import 'package:supabase_flutter/supabase_flutter.dart'; // 추가
import 'env.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:in_app_update/in_app_update.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  KakaoSdk.init(nativeAppKey: Env.kakaoNativeAppKey);

  // Supabase 초기화 추가
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);

  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(ChildProfileAdapter()); // ✅ 추가
  await Hive.openBox<Schedule>('schedules');
  await Hive.openBox<ChildProfile>('profiles'); // ✅ 추가

  try {
    await AlarmService.init();
  } catch (e) {
    debugPrint('AlarmService 초기화 오류: $e');
  }
  await MobileAds.instance.initialize();

  // 인앱 업데이트 체크
  try {
    final updateInfo = await InAppUpdate.checkForUpdate();
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    }
  } catch (e) {
    debugPrint('인앱 업데이트 체크 오류: $e');
  }

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
