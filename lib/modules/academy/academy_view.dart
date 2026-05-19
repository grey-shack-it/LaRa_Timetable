import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../home/home_view.dart';
import 'academy_controller.dart';

class AcademyView extends StatelessWidget {
  const AcademyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademyController());

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
      body: Obx(() {
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
          itemCount: controller.academyList.length,
          itemBuilder: (context, index) {
            final academy = controller.academyList[index];
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
                  // 상세 화면 (다음 단계)
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainPurple,
        onPressed: () {
          // 직접 추가 (다음 단계)
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
