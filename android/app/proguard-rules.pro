# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Timezone
-keep class org.threeten.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

# Hive
-keep class com.hive.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Sign In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Supabase / OkHttp
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Kakao SDK
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**