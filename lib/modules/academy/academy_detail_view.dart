import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import 'academy_controller.dart';
import 'dart:convert';
import 'kakao_address_search.dart';

class AcademyDetailView extends StatefulWidget {
  final Map<String, dynamic> academy;
  const AcademyDetailView({super.key, required this.academy});

  @override
  State<AcademyDetailView> createState() => _AcademyDetailViewState();
}

class _AcademyDetailViewState extends State<AcademyDetailView> {
  final AcademyController controller = Get.find<AcademyController>();
  late final RxBool isEditing;
  late final TextEditingController nameCtrl;
  late final TextEditingController subjectCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController kakaoCtrl;
  late final TextEditingController shuttleCtrl;
  late final TextEditingController feeCtrl;
  late final TextEditingController memoCtrl;
  late final TextEditingController cycleCustomCtrl;
  late final TextEditingController addressDetailCtrl;
  late final RxString selectedCycle;
  late final RxInt paymentDay;
  late final RxBool paymentAlarm;
  late final RxInt paymentAlarmDays;

  final cycles = ['매월', '격주', '분기', '반기', '기타'];

  @override
  void initState() {
    super.initState();
    isEditing = RxBool(widget.academy['id'] == null);
    nameCtrl = TextEditingController(text: widget.academy['name'] ?? '');
    subjectCtrl = TextEditingController(text: widget.academy['subject'] ?? '');
    phoneCtrl = TextEditingController(text: widget.academy['phone'] ?? '');
    kakaoCtrl = TextEditingController(text: widget.academy['kakao'] ?? '');
    shuttleCtrl = TextEditingController(
      text: widget.academy['shuttle_location'] ?? '',
    );
    feeCtrl = TextEditingController(
      text: widget.academy['fee'] != null && widget.academy['fee'] != 0
          ? widget.academy['fee'].toString()
          : '',
    );
    memoCtrl = TextEditingController(text: widget.academy['memo'] ?? '');
    cycleCustomCtrl = TextEditingController(
      text: widget.academy['payment_cycle_custom'] ?? '',
    );
    addressDetailCtrl = TextEditingController(
      text: widget.academy['address_detail'] ?? '',
    );
    selectedCycle = RxString(widget.academy['payment_cycle'] ?? '매월');
    paymentDay = RxInt(widget.academy['payment_day'] ?? 1);
    paymentAlarm = RxBool(widget.academy['payment_alarm'] ?? false);
    paymentAlarmDays = RxInt(widget.academy['payment_alarm_days'] ?? 1);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    subjectCtrl.dispose();
    phoneCtrl.dispose();
    kakaoCtrl.dispose();
    shuttleCtrl.dispose();
    feeCtrl.dispose();
    memoCtrl.dispose();
    cycleCustomCtrl.dispose();
    addressDetailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        backgroundColor: AppColors.lightPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPurple),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.academy['name'] ?? '학원 정보',
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
                if (isEditing.value) {
                  if (widget.academy['id'] == null) {
                    // 새로 추가
                    await controller.insertAcademy({
                      'child_id': widget.academy['child_id'],
                      'name': nameCtrl.text,
                      'subject': subjectCtrl.text,
                      'phone': phoneCtrl.text,
                      'kakao': kakaoCtrl.text,
                      'shuttle_location': shuttleCtrl.text,
                      'fee': int.tryParse(feeCtrl.text) ?? 0,
                      'payment_cycle': selectedCycle.value,
                      'payment_cycle_custom': cycleCustomCtrl.text,
                      'payment_day': paymentDay.value,
                      'payment_alarm': paymentAlarm.value,
                      'payment_alarm_days': paymentAlarmDays.value,
                      'memo': memoCtrl.text,
                      'address_full': widget.academy['address_full'], // ✅ 추가
                      'address_sido': widget.academy['address_sido'], // ✅ 추가
                      'address_sigungu':
                          widget.academy['address_sigungu'], // ✅ 추가
                      'address_dong': widget.academy['address_dong'], // ✅ 추가
                      'address_detail': addressDetailCtrl.text, // ✅ 추가
                    });
                    Get.back();
                  } else {
                    // 기존 수정
                    await controller.updateAcademy(widget.academy['id'], {
                      'name': nameCtrl.text,
                      'subject': subjectCtrl.text,
                      'phone': phoneCtrl.text,
                      'kakao': kakaoCtrl.text,
                      'shuttle_location': shuttleCtrl.text,
                      'fee': int.tryParse(feeCtrl.text) ?? 0,
                      'payment_cycle': selectedCycle.value,
                      'payment_cycle_custom': cycleCustomCtrl.text,
                      'payment_day': paymentDay.value,
                      'payment_alarm': paymentAlarm.value,
                      'payment_alarm_days': paymentAlarmDays.value,
                      'memo': memoCtrl.text,
                      'address_full': widget.academy['address_full'],
                      'address_sido': widget.academy['address_sido'],
                      'address_sigungu': widget.academy['address_sigungu'],
                      'address_dong': widget.academy['address_dong'],
                      'address_detail': addressDetailCtrl.text,
                    });
                    isEditing.value = false;
                  }
                } else {
                  isEditing.value = true;
                }
              },
              child: Text(
                isEditing.value ? '저장' : '편집',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            children: [
              // 📍 기본 정보
              _sectionCard(
                icon: '📍',
                title: '기본 정보',
                children: [
                  _fieldRow('학원명', nameCtrl, isEditing.value),
                  _fieldRow('과목', subjectCtrl, isEditing.value),
                  _addressRow(isEditing.value),
                  _fieldRow('상세주소', addressDetailCtrl, isEditing.value),
                ],
              ),
              const SizedBox(height: 12),

              // 📞 연락처
              _sectionCard(
                icon: '📞',
                title: '연락처',
                children: [
                  _fieldRow(
                    '전화번호',
                    phoneCtrl,
                    isEditing.value,
                    keyboardType: TextInputType.phone,
                  ),
                  _fieldRow('카카오톡', kakaoCtrl, isEditing.value),
                ],
              ),
              const SizedBox(height: 12),

              // 🚌 셔틀위치
              _sectionCard(
                icon: '🚌',
                title: '셔틀 위치',
                children: [_fieldRow('셔틀 위치', shuttleCtrl, isEditing.value)],
              ),
              const SizedBox(height: 12),

              // 💰 결제 정보
              _sectionCard(
                icon: '💰',
                title: '결제 정보',
                children: [
                  _fieldRow(
                    '학원비',
                    feeCtrl,
                    isEditing.value,
                    keyboardType: TextInputType.number,
                    suffix: '원',
                  ),
                  _cycleRow(isEditing.value),
                  if (selectedCycle.value == '기타')
                    _fieldRow('직접 입력', cycleCustomCtrl, isEditing.value),
                  _paymentDayRow(isEditing.value),
                  _alarmRow(isEditing.value),
                ],
              ),
              const SizedBox(height: 12),

              // 📝 메모
              _sectionCard(
                icon: '📝',
                title: '메모',
                children: [
                  TextField(
                    controller: memoCtrl,
                    enabled: isEditing.value,
                    maxLines: isEditing.value ? 4 : null,
                    decoration: InputDecoration(
                      hintText: '레벨테스트, 상담 내용 등',
                      border: isEditing.value
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ],
              ),
              // 삭제 버튼 (편집 모드일 때만 표시)
              Obx(
                () => isEditing.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15), // 메모 섹션과 간격
                        child: IconButton(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('학원 삭제'),
                                content: Text(
                                  '[${widget.academy['name']}] 학원 정보를 삭제할까요?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await controller.deleteAcademy(
                                        widget.academy['id'],
                                      );
                                      Get.back();
                                      Get.back();
                                    },
                                    child: const Text(
                                      '삭제',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.redAccent,
                            size: 32,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
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

  Widget _fieldRow(
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

  Widget _cycleRow(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '결제 주기',
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isEditing)
            Expanded(
              child: Wrap(
                spacing: 6,
                children: cycles.map((c) {
                  return GestureDetector(
                    onTap: () => selectedCycle.value = c,
                    child: Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: selectedCycle.value == c
                              ? AppColors.mainPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.mainPurple),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            color: selectedCycle.value == c
                                ? Colors.white
                                : AppColors.darkPurple,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Obx(
              () => Text(
                selectedCycle.value,
                style: const TextStyle(color: AppColors.darkPurple),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paymentDayRow(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '결제일',
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isEditing)
            Expanded(
              child: Obx(
                () => Column(
                  children: [
                    Slider(
                      value: paymentDay.value.toDouble(),
                      min: 1,
                      max: 31,
                      divisions: 30,
                      activeColor: AppColors.mainPurple,
                      label: '${paymentDay.value}일',
                      onChanged: (v) => paymentDay.value = v.toInt(),
                    ),
                    Text(
                      '${paymentDay.value}일',
                      style: const TextStyle(color: AppColors.darkPurple),
                    ),
                  ],
                ),
              ),
            )
          else
            Obx(
              () => Text(
                '${paymentDay.value}일',
                style: const TextStyle(color: AppColors.darkPurple),
              ),
            ),
        ],
      ),
    );
  }

  Widget _alarmRow(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '결제 알림',
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(
            () => Switch(
              value: paymentAlarm.value,
              activeColor: AppColors.mainPurple,
              onChanged: isEditing ? (v) => paymentAlarm.value = v : null,
            ),
          ),
          Obx(() {
            if (!paymentAlarm.value) return const SizedBox.shrink();
            return isEditing
                ? DropdownButton<int>(
                    value: paymentAlarmDays.value,
                    items: List.generate(7, (i) => i + 1)
                        .map(
                          (d) =>
                              DropdownMenuItem(value: d, child: Text('$d일 전')),
                        )
                        .toList(),
                    onChanged: (v) => paymentAlarmDays.value = v!,
                  )
                : Text(
                    '${paymentAlarmDays.value}일 전',
                    style: const TextStyle(color: AppColors.darkPurple),
                  );
          }),
        ],
      ),
    );
  }

  Widget _addressRow(bool isEditing) {
    final address = widget.academy['address_full'];
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
                        setState(() {
                          widget.academy['address_full'] = data['address_full'];
                          widget.academy['address_sido'] = data['address_sido'];
                          widget.academy['address_sigungu'] =
                              data['address_sigungu'];
                          widget.academy['address_dong'] = data['address_dong'];
                        });
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
  }
}
