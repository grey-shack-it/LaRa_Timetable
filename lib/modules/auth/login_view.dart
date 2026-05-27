import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../academy/academy_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 120, // 크기 줄여서 꽉 차게
                  height: 120,
                  fit: BoxFit.cover, // 꽉 채우기
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                '라라시간표',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '간편한 로그인으로 아이들 학원 정보를 관리하세요',
                style: TextStyle(fontSize: 16, color: AppColors.darkPurple),
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () async {
                  await AuthService.signInWithGoogle();
                  // 로그인 성공하면 학원정보 화면으로 이동
                  if (AuthService.currentUser != null) {
                    Get.offAll(() => const AcademyView());
                  }
                },
                child: Image.asset('assets/images/google_logo.png', width: 200),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  await AuthService.signInWithKakao();
                  if (AuthService.currentUser != null) {
                    Get.offAll(() => const AcademyView());
                  }
                },
                child: Image.asset('assets/images/kakao_login.png', width: 200),
              ),
              const SizedBox(height: 24), // 로그인 버튼들과의 간격 조절
              //  [추가] 로그인 없이 사용하기 버튼
              TextButton(
                onPressed: () {
                  Get.offAll(() => const HomeView());
                },
                child: const Text(
                  '로그인 없이 시간표 사용하기',
                  style: TextStyle(
                    color: Colors.grey, // 너무 튀지 않게 차분한 회색조 추천
                    fontSize: 18,
                    decoration: TextDecoration.underline, // 밑줄을 그어 버튼임을 인지시킴
                  ),
                ),
              ),

              const SizedBox(height: 50), // 버튼들과의 간격
              TextButton(
                onPressed: () async {
                  // 개인정보처리방침 링크(구글 사이트로 연결)
                  final Uri url = Uri.parse(
                    'https://sites.google.com/view/larapapa/홈',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  '개인정보처리방침',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    decoration: TextDecoration.underline, // 링크처럼 보이게 밑줄
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
