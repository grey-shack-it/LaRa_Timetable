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
      // 로딩 표시
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 시간표 이미지 캡처
      final Uint8List? timeTableImage = await screenshotController.capture(
        pixelRatio: 3.0, // 고화질
      );

      if (timeTableImage == null) {
        Get.back();
        return;
      }

      // 배너 합성 후 저장
      final finalImage = await _composeFinalImage(timeTableImage, controller);

      // 갤러리에 저장
      final result = await SaverGallery.saveFile(
        filePath: finalImage,
        fileName: 'larapapa_${DateTime.now().millisecondsSinceEpoch}',
        androidRelativePath: 'Pictures/라라 시간표',
        skipIfExists: false,
      );

      Get.back(); // 로딩 닫기

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
        // ✅ 추가
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

    final int ttWidth = ttImage.width;
    final int ttHeight = ttImage.height;
    final int topPadding = (ttWidth * 0.1).toInt();
    final int bottomPadding = (ttWidth * 0.1).toInt();
    final int topBannerHeight = (ttWidth * 0.10).toInt(); // ✅ 상단 배너 높이
    final int bannerHeight = (ttWidth * 0.2).toInt(); // 하단배너 높이

    // ✅ 로고 + QR 이미지 불러오기
    final ByteData logoData = await rootBundle.load(
      'assets/images/larapapa.png',
    );
    final ui.Image logoImage = await decodeImageFromList(
      logoData.buffer.asUint8List(),
    );

    final ByteData qrData = await rootBundle.load('assets/images/qr_code.png');
    final ui.Image qrImage = await decodeImageFromList(
      qrData.buffer.asUint8List(),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 전체 배경 (연보라)
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        ttWidth.toDouble(),
        (ttHeight + bannerHeight + topBannerHeight + topPadding + bottomPadding)
            .toDouble(),
      ),
      Paint()..color = const Color(0xFFE5D9F9),
    );

    // ✅ 상단 패딩 검은색
    canvas.drawRect(
      Rect.fromLTWH(0, 0, ttWidth.toDouble(), topPadding.toDouble()),
      Paint()..color = Colors.black,
    );

    // ✅ 상단 배너 배경
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        topPadding.toDouble(),
        ttWidth.toDouble(),
        topBannerHeight.toDouble(),
      ),
      Paint()..color = const Color(0xFFE5D9F9),
    );

    // ✅ 상단 배너 타이틀 텍스트
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
        (ttWidth - titlePainter.width) / 2, // 가운데 정렬
        topPadding + (topBannerHeight - titlePainter.height) / 2,
      ),
    );

    // 시간표 그리기 (상단 배너 아래로)
    canvas.drawImage(
      ttImage,
      Offset(0, (topBannerHeight + topPadding).toDouble()),
      Paint(),
    );

    // 배너 배경 흰색
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        (ttHeight + topPadding).toDouble(),
        ttWidth.toDouble(),
        bannerHeight.toDouble(),
      ),
      Paint()..color = Colors.white,
    );

    // 구분선
    canvas.drawLine(
      Offset(0, (ttHeight + topPadding).toDouble()),
      Offset(ttWidth.toDouble(), (ttHeight + topPadding).toDouble()),
      Paint()
        ..color = const Color(0xFF9F75E3)
        ..strokeWidth = 2,
    );

    // 배너를 3등분
    final double sectionWidth = ttWidth / 3;
    final double bannerTop = (ttHeight + topPadding).toDouble();
    final double itemSize = bannerHeight * 0.98; // 아이콘/QR 크기 (배너 높이의 90%)
    final double logoSize = bannerHeight * 0.98; // 로고는 배너 높이의 100%로

    // ✅ 왼쪽 - 홍보 문구
    final textPainter = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: '복잡한 아이들 학원시간\n이제 한눈에 쏙!\n',
            style: TextStyle(
              color: Color(0xFF9F75E3),
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: '라라 시간표',
            style: TextStyle(
              color: Color(0xFFC09FF8),
              fontSize: 45,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: sectionWidth - 20);
    final double textY = bannerTop + (bannerHeight - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(20, textY));

    // ✅ 가운데 - 로고
    final double logoX = sectionWidth + (sectionWidth - logoSize) / 2;
    final double logoY = bannerTop + (bannerHeight - logoSize) / 2;
    canvas.drawImageRect(
      logoImage,
      Rect.fromLTWH(
        0,
        0,
        logoImage.width.toDouble(),
        logoImage.height.toDouble(),
      ),
      Rect.fromLTWH(logoX, logoY, logoSize, logoSize), // ✅ logoSize 사용
      Paint(),
    );

    // ✅ 오른쪽 - QR코드
    final double qrSize = itemSize * 0.9;
    final double qrX = sectionWidth * 2 + (sectionWidth - qrSize) / 2;
    final double qrY = bannerTop + (bannerHeight - qrSize) / 2;
    canvas.drawImageRect(
      qrImage,
      Rect.fromLTWH(0, 0, qrImage.width.toDouble(), qrImage.height.toDouble()),
      Rect.fromLTWH(qrX, qrY, qrSize, qrSize),
      Paint(),
    );
    // ✅ 하단 패딩 검은색
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        (ttHeight + bannerHeight + topBannerHeight + topPadding).toDouble(),
        ttWidth.toDouble(),
        bottomPadding.toDouble(),
      ),
      Paint()..color = Colors.black,
    );
    // 최종 이미지 생성
    final picture = recorder.endRecording();
    final ui.Image finalImg = await picture.toImage(
      ttWidth,
      ttHeight + bannerHeight + topBannerHeight + topPadding + bottomPadding,
    );
    final ByteData? byteData = await finalImg.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/larapapa_timetable.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    return file.path;
  }
}
