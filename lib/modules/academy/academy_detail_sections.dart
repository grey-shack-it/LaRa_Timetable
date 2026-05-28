import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../constants/app_colors.dart';
import 'academy_detail_controller.dart';
import 'kakao_address_search.dart';
import 'package:url_launcher/url_launcher.dart';

class AcademyDetailSections {
  // 섹션 카드 공통 레이아웃
  static Widget sectionCard({
    required String icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPurple.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon $title',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.darkPurple,
            ),
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  // 공통 텍스트 필드 행
  static Widget fieldRow(
    String label,
    TextEditingController ctrl,
    bool isEditing, {
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: ctrl,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixText: suffix,
                    ),
                  )
                : Text(
                    ctrl.text.isEmpty ? '-' : '${ctrl.text}${suffix ?? ''}',
                    style: const TextStyle(color: AppColors.darkPurple),
                  ),
          ),
        ],
      ),
    );
  }

  // 주소 행
  static Widget addressRow(
    bool isEditing,
    Map<String, dynamic> academy,
    RxString addressFull,
    Function(Map<String, dynamic>) onAddressChanged,
  ) {
    return Obx(() {
      final address = addressFull.value.isEmpty ? null : addressFull.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const SizedBox(
              width: 80,
              child: Text(
                '주소',
                style: TextStyle(
                  color: AppColors.darkPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: isEditing
                  ? GestureDetector(
                      onTap: () async {
                        final result = await Get.to(
                          () => const KakaoAddressSearch(),
                        );
                        if (result != null) {
                          final data = jsonDecode(result);
                          onAddressChanged(data);
                          addressFull.value = data['address_full'] ?? '';
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address ?? '주소를 검색해주세요',
                          style: TextStyle(
                            color: address != null
                                ? AppColors.darkPurple
                                : Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      address ?? '-',
                      style: const TextStyle(color: AppColors.darkPurple),
                    ),
            ),
          ],
        ),
      );
    });
  }

  // 학원비 행
  static Widget feeRow(AcademyDetailController ctrl, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '학원비',
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: ctrl.feeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      suffixText: '원',
                    ),
                  )
                : Text(
                    ctrl.feeCtrl.text.isEmpty
                        ? '-'
                        : '${ctrl.formatFee(ctrl.feeCtrl.text)}원',
                    style: const TextStyle(color: AppColors.darkPurple),
                  ),
          ),
        ],
      ),
    );
  }

  // 연락처 섹션
  static Widget contactSection(AcademyDetailController ctrl, bool isEditing) {
    return sectionCard(
      icon: '📞',
      title: '연락처',
      children: [
        // 전화번호 행
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '전화번호',
                  style: TextStyle(
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: ctrl.phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        ctrl.phoneCtrl.text.isEmpty ? '-' : ctrl.phoneCtrl.text,
                        style: const TextStyle(color: AppColors.darkPurple),
                      ),
              ),
              if (!isEditing && ctrl.phoneCtrl.text.isNotEmpty) ...[
                IconButton(
                  onPressed: () => _makeCall(ctrl.phoneCtrl.text),
                  icon: const Icon(
                    Icons.call,
                    color: AppColors.mainPurple,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendSms(ctrl.phoneCtrl.text),
                  icon: const Icon(
                    Icons.sms,
                    color: AppColors.mainPurple,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),

        // 오픈채팅 행
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '오픈채팅',
                  style: TextStyle(
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: ctrl.kakaoOpenchatCtrl,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        ctrl.kakaoOpenchatCtrl.text.isEmpty
                            ? '-'
                            : ctrl.kakaoOpenchatCtrl.text,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.darkPurple),
                      ),
              ),
              if (!isEditing && ctrl.kakaoOpenchatCtrl.text.isNotEmpty)
                IconButton(
                  onPressed: () => _openKakao(ctrl.kakaoOpenchatCtrl.text),
                  icon: Image.asset(
                    'assets/images/kakao_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),

        // 웹사이트 행
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '웹사이트',
                  style: TextStyle(
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: ctrl.websiteCtrl,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        ctrl.websiteCtrl.text.isEmpty
                            ? '-'
                            : ctrl.websiteCtrl.text,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.darkPurple),
                      ),
              ),
              if (!isEditing && ctrl.websiteCtrl.text.isNotEmpty)
                IconButton(
                  onPressed: () => _openWebsite(ctrl.websiteCtrl.text),
                  icon: const Icon(
                    Icons.language,
                    color: AppColors.mainPurple,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 전화
  static Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // 문자
  static Future<void> _sendSms(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // 카카오 오픈채팅
  static Future<void> _openKakao(String kakaoUrl) async {
    final uri = Uri.parse(kakaoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        '오픈채팅',
        '카카오톡이 설치되어 있지 않아요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 웹사이트
  static Future<void> _openWebsite(String url) async {
    String inputUrl = url.trim();
    if (!inputUrl.startsWith('http://') && !inputUrl.startsWith('https://')) {
      inputUrl = 'https://$inputUrl';
    }
    final uri = Uri.parse(inputUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        '알림',
        '웹사이트를 열 수 없습니다. 주소를 확인해 주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
