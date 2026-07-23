import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../data/schedule.dart';
import 'schedule_dialog_helpers.dart';

class ScheduleBlock extends StatelessWidget {
  final HomeController controller;
  final Schedule schedule;
  final int startHour;
  final VoidCallback onTap;

  const ScheduleBlock({
    super.key,
    required this.controller,
    required this.schedule,
    required this.startHour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double startMinutes =
        (schedule.startTime.hour * 60 + schedule.startTime.minute).toDouble();
    final double endMinutes =
        (schedule.endTime.hour * 60 + schedule.endTime.minute).toDouble();
    final double blockHeight = (endMinutes - startMinutes).clamp(
      20.0,
      double.infinity,
    );
    final double topOffset = startMinutes - (startHour * 60.0);

    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: blockHeight,

      child: GestureDetector(
        onTap: onTap,
        child: Obx(() {
          final isOverlap = controller.isOverlapView.value;
          final hasConflict = controller.isOverlappingWithOthers(schedule);
          return Opacity(
            opacity: isOverlap && hasConflict ? 0.75 : 1.0,
            child: _buildBlockDesign(blockHeight),
          );
        }),
      ),
    );
  }

  Widget _buildBlockDesign(double height) {
    double iconSize = height < 50 ? 28.0 : (height < 70 ? 40.0 : 52.0);

    return Obx(() {
      final isOverlap = controller.isOverlapView.value;
      final profileColor = controller.getProfileColor(schedule.childId);
      final profileName = controller.getProfileName(schedule.childId);

      return Container(
        decoration: BoxDecoration(
          color: isOverlap && controller.isOverlappingWithOthers(schedule)
              ? Colors
                    .white // ✅ 겹칠 때 흰색
              : Color(schedule.colorValue), // 겹치지 않을 때 기존 색
          borderRadius: BorderRadius.circular(12),
          border: isOverlap && controller.isOverlappingWithOthers(schedule)
              ? Border.all(color: AppColors.darkPurple, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPurple.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (schedule.iconName != null)
                  Flexible(
                    child: Center(
                      child: buildAcademyIcon(
                        schedule.iconName!,
                        size: iconSize,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    schedule.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 99, 98, 98),
                          offset: Offset(0.5, 0.5),
                          blurRadius: 3.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isOverlap)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: profileColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    profileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
