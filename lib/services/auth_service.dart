import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_timeline_app/env.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:flutter/material.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  // 구글 로그인
  static Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: Env.googleAndroidClientId,
        serverClientId: Env.googleWebClientId,
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.idToken,
      );

      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').upsert({'id': user.id});
      }
    } catch (e) {
      debugPrint('구글 로그인 오류: $e');
    }
  }

  // 카카오 로그인
  static Future<void> signInWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.idToken!,
      );

      // ✅ 로그인 후 profiles에 없으면 자동 추가
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').upsert({'id': user.id});
      }
    } catch (e) {
      debugPrint('카카오 로그인 오류: $e');
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
    await _supabase.auth.signOut();
  }

  static Future<void> deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        // 1. 서버 삭제 함수 호출
        await Supabase.instance.client.functions.invoke('delete-user');

        // 2. 로그아웃 (이후 앱의 인증 감지 로직에 의해 LoginView로 자동 전환됨)
        await signOut();
      } catch (e) {
        debugPrint('탈퇴 처리 중 오류 발생: $e');
        // 필요하다면 에러 발생 시 사용자에게 알림을 띄우는 로직 추가
      }
    }
  }

  static dynamic get currentUser => _supabase.auth.currentUser;
}
