import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../home/home_view.dart';
import 'academy_controller.dart';
import '../home/home_controller.dart';
import 'academy_detail_view.dart';

class AcademyView extends StatelessWidget {
  const AcademyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademyController(), permanent: false);
    final homeController = Get.find<HomeController>(); // 여기에 추가

    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppColors.darkPurple),
          onPressed: () => Get.offAll(() => HomeView()),
        ),
        title: const Text(
          '학원 정보',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.darkPurple,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightPurple,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await AuthService.signOut();
              Get.offAll(() => HomeView());
            },
            child: const Text(
              'Log-out',
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭바
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...homeController.profiles.map((profile) {
                    final isSelected =
                        controller.selectedChildId.value == profile.id;
                    return GestureDetector(
                      onTap: () {
                        controller.isOverlapView.value = false;
                        controller.selectedChildId.value = profile.id;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mainPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkPurple.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          profile.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkPurple,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // 한눈에 버튼
                  Obx(
                    () => GestureDetector(
                      onTap: () => controller.isOverlapView.value =
                          !controller.isOverlapView.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: controller.isOverlapView.value
                              ? AppColors.darkPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkPurple.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt,
                              size: 16,
                              color: controller.isOverlapView.value
                                  ? Colors.white
                                  : AppColors.darkPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '한눈에',
                              style: TextStyle(
                                color: controller.isOverlapView.value
                                    ? Colors.white
                                    : AppColors.darkPurple,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.academyList.isEmpty) {
                return const Center(
                  child: Text(
                    '등록된 학원이 없어요\n+ 버튼으로 추가해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkPurple, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.displayAcademyList.length,
                itemBuilder: (context, index) {
                  final academy = controller.displayAcademyList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        academy['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkPurple,
                        ),
                      ),
                      subtitle: Text(academy['subject'] ?? ''),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.darkPurple,
                      ),
                      onTap: () {
                        Get.to(() => AcademyDetailView(academy: academy));
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      //직접 추가하기
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainPurple,
        onPressed: () {
          Get.to(
            () => AcademyDetailView(
              academy: {'child_id': controller.selectedChildId.value},
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
