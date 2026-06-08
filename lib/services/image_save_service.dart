import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../modules/home/home_controller.dart';
import '../constants/app_colors.dart';

class ImageSaveService {
  static Future<void> saveTimeTable(
    ScreenshotController screenshotController,
    HomeController controller,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final Uint8List? timeTableImage = await screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (timeTableImage == null) {
        Get.back();
        return;
      }

      final finalImage = await _composeFinalImage(timeTableImage, controller);

      final result = await SaverGallery.saveFile(
        filePath: finalImage,
        fileName: 'larapapa_${DateTime.now().millisecondsSinceEpoch}',
        albumPath: 'Pictures/라라 시간표',
        skipIfExists: false,
      );

      Get.back();

      if (result.isSuccess) {
        Get.snackbar(
          '저장 완료! 📸',
          '갤러리 [라라 시간표] 앨범에 저장되었어요!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.mainPurple,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          '저장 실패',
          '갤러리 저장에 실패했어요. 저장 권한을 확인해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        '저장 실패',
        '이미지 저장 중 오류가 발생했어요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  static Future<String> _composeFinalImage(
    Uint8List timeTableImage,
    HomeController controller,
  ) async {
    final ui.Image ttImage = await decodeImageFromList(timeTableImage);

    // ✅ 각 영역 높이 정의
    final int ttWidth = ttImage.width;
    final int ttHeight = ttImage.height;
    final int topPadding = (ttWidth * 0.1).toInt(); // 상단 검은 여백
    final int topBannerHeight = (ttWidth * 0.10).toInt(); // 타이틀 배너
    final int bottomBannerHeight = (ttWidth * 0.2).toInt(); // 홍보 배너
    final int bottomPadding = (ttWidth * 0.1).toInt(); // 하단 검은 여백

    // ✅ Y축 위치 계산
    final int titleBannerTop = topPadding;
    final int timeTableTop = topPadding + topBannerHeight;
    final int bottomBannerTop = topPadding + topBannerHeight + ttHeight;
    final int bottomPaddingTop =
        topPadding + topBannerHeight + ttHeight + bottomBannerHeight;
    final int totalHeight = bottomPaddingTop + bottomPadding;

    // ✅ 배너 이미지 로드 (기존 로고+QR+텍스트 대신 단일 PNG)
    final ByteData bannerData = await rootBundle.load(
      'assets/images/banner_bottom.png',
    );
    final ui.Image bannerImage = await decodeImageFromList(
      bannerData.buffer.asUint8List(),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. 전체 배경 (연보라)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, ttWidth.toDouble(), totalHeight.toDouble()),
      Paint()..color = const Color(0xFFE5D9F9),
    );

    // 2. 상단 검은 여백
    canvas.drawRect(
      Rect.fromLTWH(0, 0, ttWidth.toDouble(), topPadding.toDouble()),
      Paint()..color = Colors.black,
    );

    // 3. 타이틀 텍스트
    final title = controller.isOverlapView.value
        ? '아이들 시간표'
        : '${controller.getProfileName(controller.selectedChildId.value)}의 시간표';

    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Color(0xFF9F75E3),
          fontSize: 60,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: ttWidth.toDouble());
    titlePainter.paint(
      canvas,
      Offset(
        (ttWidth - titlePainter.width) / 2,
        titleBannerTop + (topBannerHeight - titlePainter.height) / 2,
      ),
    );

    // 4. 시간표 이미지
    canvas.drawImage(ttImage, Offset(0, timeTableTop.toDouble()), Paint());

    // 5. 구분선
    canvas.drawLine(
      Offset(0, bottomBannerTop.toDouble()),
      Offset(ttWidth.toDouble(), bottomBannerTop.toDouble()),
      Paint()
        ..color = const Color(0xFF9F75E3)
        ..strokeWidth = 2,
    );

    // 6. ✅ 홍보 배너 — 단일 PNG 이미지로 교체
    canvas.drawImageRect(
      bannerImage,
      Rect.fromLTWH(
        0,
        0,
        bannerImage.width.toDouble(),
        bannerImage.height.toDouble(),
      ),
      Rect.fromLTWH(
        0,
        bottomBannerTop.toDouble(),
        ttWidth.toDouble(),
        bottomBannerHeight.toDouble(),
      ),
      Paint(),
    );

    // 7. 하단 검은 여백 (맨 마지막에 그려야 덮어씌워지지 않음)
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        bottomPaddingTop.toDouble(),
        ttWidth.toDouble(),
        bottomPadding.toDouble(),
      ),
      Paint()..color = Colors.black,
    );

    // 최종 이미지 생성
    final picture = recorder.endRecording();
    final ui.Image finalImg = await picture.toImage(ttWidth, totalHeight);
    final ByteData? byteData = await finalImg.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/larapapa_timetable.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    return file.path;
  }
}
