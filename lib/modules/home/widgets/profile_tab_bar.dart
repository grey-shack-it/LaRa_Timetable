import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';
import '../widgets/profile_manage_sheet.dart';

class ProfileTabBar extends StatelessWidget {
  final HomeController controller;

  const ProfileTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...controller.profiles.map((profile) {
              final isSelected = controller.selectedChildId.value == profile.id;
              return GestureDetector(
                onTap: () {
                  controller.isOverlapView.value = false;
                  controller.selectedChildId.value = profile.id;
                  controller.refreshUI();
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
                    color: isSelected ? AppColors.mainPurple : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPurple.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    profile.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkPurple,
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
                onTap: () {
                  controller.isOverlapView.value =
                      !controller.isOverlapView.value;
                  controller.refreshUI();
                },
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
                        color: AppColors.darkPurple.withValues(alpha: 0.15),
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
            GestureDetector(
              onTap: () => ProfileManageSheet.show(Get.context!, controller),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPurple.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.darkPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
