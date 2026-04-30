import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';

class ProfileManageSheet {
  static void show(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      Obx(
        () => Container(
          height: MediaQuery.of(Get.context!).size.height * 0.65,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '아이 프로필 관리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(height: 16),

              // 프로필 목록
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: controller.profiles.map((profile) {
                    final nameController = TextEditingController(
                      text: profile.name,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.child_care,
                            color: AppColors.mainPurple,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onSubmitted: (val) =>
                                  controller.updateProfile(profile.id, val),
                              onEditingComplete: () {
                                controller.updateProfile(
                                  profile.id,
                                  nameController.text,
                                );
                                FocusScope.of(Get.context!).unfocus();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: AppColors.mainPurple,
                            ),
                            onPressed: () {
                              controller.updateProfile(
                                profile.id,
                                nameController.text.trim(),
                              );
                              FocusScope.of(Get.context!).unfocus();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: controller.profiles.length > 1
                                  ? Colors.redAccent
                                  : Colors.grey,
                            ),
                            onPressed: controller.profiles.length > 1
                                ? () => _confirmDelete(
                                    controller,
                                    profile.id,
                                    profile.name,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // 아이 추가 버튼
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(controller),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '아이 추가',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainPurple,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ignoreSafeArea: false,
    );
  }

  static void _showAddDialog(HomeController controller) {
    final nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('아이 추가'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: '이름을 입력하세요'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.darkPurple),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.addProfile(nameController.text.trim());
                Get.back();
              }
            },
            child: const Text(
              '추가',
              style: TextStyle(color: AppColors.darkPurple),
            ),
          ),
        ],
      ),
    );
  }

  static void _confirmDelete(
    HomeController controller,
    String id,
    String name,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('프로필 삭제'),
        content: Text('[$name]의 프로필과 모든 일정을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              controller.deleteProfile(id);
              Get.back();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
