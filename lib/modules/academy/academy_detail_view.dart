import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import 'academy_controller.dart';
import 'academy_detail_controller.dart';
import 'academy_detail_sections.dart';
import 'academy_detail_payment.dart';
import '../home/home_controller.dart';

class AcademyDetailView extends StatelessWidget {
  final Map<String, dynamic> academy;
  const AcademyDetailView({super.key, required this.academy});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AcademyDetailController(academy: academy));
    final academyCtrl = Get.find<AcademyController>();
    final homeController = Get.find<HomeController>();

    return Obx(() => Scaffold(
      backgroundColor: homeController.bgColor.value,
      appBar: AppBar(
        backgroundColor: homeController.bgColor.value,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPurple),
          onPressed: () => Get.back(),
        ),
        title: Text(
          academy['name'] ?? '학원 정보',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.darkPurple,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => TextButton(
              onPressed: () async {
                if (ctrl.isEditing.value) {
                  // 학원명 필수 체크
                  if (ctrl.nameCtrl.text.trim().isEmpty) {
                    Get.snackbar(
                      '입력 오류',
                      '학원명을 입력해주세요.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color.fromARGB(255, 146, 1, 182),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final saveData = ctrl.buildSaveData();

                  if (academy['id'] == null) {
                    // 새로 추가
                    await academyCtrl.insertAcademy({
                      'child_id': academy['child_id'],
                      ...saveData,
                    });
                    // 알림 등록
                    if (ctrl.paymentAlarm.value) {
                      final newAcademy = academyCtrl.academyList.lastWhere(
                        (a) =>
                            a['name'] == ctrl.nameCtrl.text &&
                            a['child_id'] == academy['child_id'],
                      );
                      await ctrl.handleAlarm(newAcademy['id']);
                    }
                    Get.back();
                  } else {
                    // 기존 수정
                    await academyCtrl.updateAcademy(academy['id'], saveData);
                    await ctrl.handleAlarm(academy['id']);
                    ctrl.isEditing.value = false;
                  }
                } else {
                  ctrl.isEditing.value = true;
                }
              },
              child: Text(
                ctrl.isEditing.value ? '저장' : '편집',
                style: const TextStyle(
                  color: AppColors.darkPurple,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => Column(
              children: [
                // 📍 기본 정보
                AcademyDetailSections.sectionCard(
                  icon: '📍',
                  title: '기본 정보',
                  children: [
                    AcademyDetailSections.fieldRow(
                      '학원명',
                      ctrl.nameCtrl,
                      ctrl.isEditing.value,
                    ),
                    AcademyDetailSections.fieldRow(
                      '과목',
                      ctrl.subjectCtrl,
                      ctrl.isEditing.value,
                    ),
                    AcademyDetailSections.addressRow(
                      ctrl.isEditing.value,
                      academy,
                      ctrl.addressFull,
                      (data) {
                        academy['address_full'] = data['address_full'];
                        academy['address_sido'] = data['address_sido'];
                        academy['address_sigungu'] = data['address_sigungu'];
                        academy['address_dong'] = data['address_dong'];
                      },
                    ),
                    AcademyDetailSections.fieldRow(
                      '상세주소',
                      ctrl.addressDetailCtrl,
                      ctrl.isEditing.value,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 📞 연락처
                AcademyDetailSections.contactSection(
                  ctrl,
                  ctrl.isEditing.value,
                ),
                const SizedBox(height: 12),

                // 🚌 셔틀위치
                AcademyDetailSections.sectionCard(
                  icon: '🚌',
                  title: '셔틀 위치',
                  children: [
                    AcademyDetailSections.fieldRow(
                      '셔틀 위치',
                      ctrl.shuttleCtrl,
                      ctrl.isEditing.value,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 💰 결제 정보
                AcademyDetailSections.sectionCard(
                  icon: '💰',
                  title: '결제 정보',
                  children: [
                    AcademyDetailSections.feeRow(ctrl, ctrl.isEditing.value),
                    AcademyDetailPayment.cycleRow(ctrl, ctrl.isEditing.value),
                    AcademyDetailPayment.paymentDayRow(
                      ctrl,
                      ctrl.isEditing.value,
                    ),
                    AcademyDetailPayment.alarmRow(ctrl, ctrl.isEditing.value),
                  ],
                ),
                const SizedBox(height: 12),

                // 📝 메모
                AcademyDetailSections.sectionCard(
                  icon: '📝',
                  title: '메모',
                  children: [
                    TextField(
                      controller: ctrl.memoCtrl,
                      enabled: ctrl.isEditing.value,
                      maxLines: ctrl.isEditing.value ? 4 : null,
                      decoration: InputDecoration(
                        hintText: '상담 내용, 레벨테스트 내용 등\n자유롭게 메모해보세요!',
                        border: ctrl.isEditing.value
                            ? const OutlineInputBorder()
                            : InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ],
                ),

                // 삭제 버튼 (편집 모드 + 기존 데이터일 때만)
                if (ctrl.isEditing.value && academy['id'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: IconButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('학원 삭제'),
                            content: Text('[${academy['name']}] 학원 정보를 삭제할까요?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await academyCtrl.deleteAcademy(
                                    academy['id'],
                                  );
                                  Get.back();
                                  Get.back();
                                },
                                child: const Text(
                                  '삭제',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 205, 104, 230),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_sweep,
                        color: Color.fromARGB(255, 205, 104, 230),
                        size: 32,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
