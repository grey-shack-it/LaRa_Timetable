import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/alarm_service.dart';
import 'academy_controller.dart';

class AcademyDetailController extends GetxController {
  final Map<String, dynamic> academy;
  final AcademyController academyController = Get.find<AcademyController>();

  // 편집 상태
  late final RxBool isEditing;

  // 텍스트 컨트롤러
  late final TextEditingController nameCtrl;
  late final TextEditingController subjectCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController kakaoOpenchatCtrl;
  late final TextEditingController websiteCtrl;
  late final TextEditingController shuttleCtrl;
  late final TextEditingController feeCtrl;
  late final TextEditingController memoCtrl;
  late final TextEditingController addressDetailCtrl;

  // 결제 관련 상태
  late final RxString selectedCycle;
  late final RxInt paymentStartMonth;
  late final RxInt paymentDay;
  late final RxBool paymentAlarm;
  late final RxInt paymentAlarmDays;
  late final RxInt paymentAlarmHour;
  late final RxInt paymentAlarmMinute;

  final cycles = ['월간', '주간', '분기', '반기', '연간'];

  AcademyDetailController({required this.academy});

  @override
  void onInit() {
    super.onInit();
    isEditing = RxBool(academy['id'] == null);
    nameCtrl = TextEditingController(text: academy['name'] ?? '');
    subjectCtrl = TextEditingController(text: academy['subject'] ?? '');
    phoneCtrl = TextEditingController(text: academy['phone'] ?? '');
    kakaoOpenchatCtrl = TextEditingController(text: academy['kakao_openchat'] ?? '');
    websiteCtrl = TextEditingController(text: academy['website'] ?? '');
    shuttleCtrl = TextEditingController(text: academy['shuttle_location'] ?? '');
    feeCtrl = TextEditingController(
      text: academy['fee'] != null && academy['fee'] != 0
          ? academy['fee'].toString()
          : '',
    );
    memoCtrl = TextEditingController(text: academy['memo'] ?? '');
    addressDetailCtrl = TextEditingController(text: academy['address_detail'] ?? '');
    selectedCycle = RxString(academy['payment_cycle'] ?? '월간');
    paymentStartMonth = RxInt(academy['payment_start_month'] ?? 1);
    paymentDay = RxInt(academy['payment_day'] ?? 1);
    paymentAlarm = RxBool(academy['payment_alarm'] ?? false);
    paymentAlarmDays = RxInt(academy['payment_alarm_days'] ?? 1);
    paymentAlarmHour = RxInt(academy['payment_alarm_hour'] ?? 9);
    paymentAlarmMinute = RxInt(academy['payment_alarm_minute'] ?? 0);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    subjectCtrl.dispose();
    phoneCtrl.dispose();
    kakaoOpenchatCtrl.dispose();
    websiteCtrl.dispose();
    shuttleCtrl.dispose();
    feeCtrl.dispose();
    memoCtrl.dispose();
    addressDetailCtrl.dispose();
    super.onClose();
  }

  // 저장할 데이터 맵 생성
  Map<String, dynamic> buildSaveData() {
    return {
      'name': nameCtrl.text,
      'subject': subjectCtrl.text,
      'phone': phoneCtrl.text,
      'kakao_openchat': kakaoOpenchatCtrl.text,
      'website': websiteCtrl.text,
      'shuttle_location': shuttleCtrl.text,
      'fee': int.tryParse(feeCtrl.text) ?? 0,
      'payment_cycle': selectedCycle.value,
      'payment_start_month': paymentStartMonth.value,
      'payment_day': paymentDay.value,
      'payment_alarm': paymentAlarm.value,
      'payment_alarm_days': paymentAlarmDays.value,
      'payment_alarm_hour': paymentAlarmHour.value,
      'payment_alarm_minute': paymentAlarmMinute.value,
      'memo': memoCtrl.text,
      'address_full': academy['address_full'],
      'address_sido': academy['address_sido'],
      'address_sigungu': academy['address_sigungu'],
      'address_dong': academy['address_dong'],
      'address_detail': addressDetailCtrl.text,
    };
  }

  // 저장 후 알림 등록/취소
  Future<void> handleAlarm(String academyId) async {
    if (paymentAlarm.value) {
      await AlarmService.schedulePaymentAlarm(
        academyId: academyId,
        academyName: nameCtrl.text,
        childName: academyController.getChildName(academy['child_id']),
        paymentDay: paymentDay.value,
        alarmDaysBefore: paymentAlarmDays.value,
        alarmHour: paymentAlarmHour.value,
        alarmMinute: paymentAlarmMinute.value,
      );
    } else {
      await AlarmService.cancelPaymentAlarm(academyId);
    }
  }

  // 학원비 천단위 콤마
  String formatFee(String fee) {
    final number = int.tryParse(fee);
    if (number == null) return fee;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
