import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../academy/academy_view.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      body: Center(
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
              '간편한 로그인으로 학원 정보를 관리하세요',
              style: TextStyle(fontSize: 16, color: AppColors.darkPurple),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: () async {
                await AuthService.signInWithGoogle();
                // 로그인 성공하면 홈으로 이동
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
            const SizedBox(height: 50), // 버튼들과의 간격
            TextButton(
              onPressed: () async {
                // 우리가 방금 업데이트한 구글 사이트 주소
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
    );
  }
}
