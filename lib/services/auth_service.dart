import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_timeline_app/env.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/foundation.dart'; // debugPrint

class AuthService {
  static final _supabase = Supabase.instance.client;

  static final _googleSignIn = GoogleSignIn(
    clientId: Env.googleAndroidClientId,
    serverClientId: Env.googleWebClientId,
  );

  static Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    // ✅ 로그인 후 profiles에 없으면 자동 추가
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from('profiles').upsert({'id': user.id});
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
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  static dynamic get currentUser => _supabase.auth.currentUser;
}
