import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/schedule.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../home/home_controller.dart';

class AcademyController extends GetxController {
  final _supabase = Supabase.instance.client;

  final RxList academyList = [].obs;
  List get displayAcademyList => isOverlapView.value
      ? academyList.toList()
      : academyList
            .where((a) => a['child_id'] == selectedChildId.value)
            .toList();
  final RxString selectedChildId = ''.obs;
  final RxBool isOverlapView = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    selectedChildId.value = homeController.selectedChildId.value;
    syncFromTimetable();
  }

  // 시간표 일정 → 학원 목록 자동 동기화
  Future<void> syncFromTimetable() async {
    isLoading.value = true;
    // ✅ profiles 먼저 확인 후 진행
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase.from('profiles').upsert({'id': user.id});
    final box = Hive.box<Schedule>('schedules');
    final schedules = box.values.toList();

    final seen = <String>{};
    final unique = schedules.where((s) {
      final key = '${s.childId}_${s.title}';
      return seen.add(key);
    }).toList();

    for (var s in unique) {
      final existing = await _supabase
          .from('academy_info')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
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
    await loadAcademyList();
  }

  // 학원 목록 불러오기
  Future<void> loadAcademyList() async {
    final data = await _supabase
        .from('academy_info')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('created_at', ascending: true); // ✅ 생성순 정렬
    academyList.assignAll(data);
    isLoading.value = false;
  }

  Future<void> updateAcademy(String id, Map<String, dynamic> data) async {
    await _supabase.from('academy_info').update(data).eq('id', id);
    await loadAcademyList();
  }

  Future<void> insertAcademy(Map<String, dynamic> data) async {
    await _supabase.from('academy_info').insert({
      'user_id': _supabase.auth.currentUser!.id,
      ...data,
    });
    await loadAcademyList();
  }

  Future<void> deleteAcademy(String id) async {
    await _supabase.from('academy_info').delete().eq('id', id);
    await loadAcademyList();
  }

  // 아이 이름 가져오기
  String getChildName(String childId) {
    final homeController = Get.find<HomeController>();
    return homeController.getProfileName(childId);
  }
}
