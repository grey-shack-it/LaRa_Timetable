import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/schedule.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../home/home_controller.dart';

class AcademyController extends GetxController {
  final _supabase = Supabase.instance.client;

  final RxList academyList = [].obs;
  final RxString selectedChildId = ''.obs;
  final RxBool isOverlapView = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 홈 컨트롤러에서 선택된 아이 ID 가져오기
    final homeController = Get.find<HomeController>();
    selectedChildId.value = homeController.selectedChildId.value;
  }

  @override
  void onReady() {
    super.onReady();
    syncFromTimetable();
    loadAcademyList();
  }

  // 시간표 일정 → 학원 목록 자동 동기화
  Future<void> syncFromTimetable() async {
    final box = Hive.box<Schedule>('schedules');
    final schedules = box.values.toList();

    // 중복 제거 (아이ID + 학원이름 조합)
    final seen = <String>{};
    final unique = schedules.where((s) {
      final key = '${s.childId}_${s.title}';
      return seen.add(key);
    }).toList();

    for (var s in unique) {
      // Supabase에 없으면 추가
      final existing = await _supabase
          .from('academy_info')
          .select()
          .eq('child_id', s.childId)
          .eq('name', s.title)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('academy_info').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'child_id': s.childId,
          'name': s.title,
          'subject': s.title,
          'fee': 0,
          'payment_cycle': '매월',
          'payment_day': 1,
        });
      }
    }
  }

  // 학원 목록 불러오기
  Future<void> loadAcademyList() async {
    isLoading.value = true;
    final data = await _supabase
        .from('academy_info')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);
    academyList.assignAll(data);
    isLoading.value = false;
  }
}
