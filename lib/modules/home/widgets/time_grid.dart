import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../constants/app_colors.dart';

class TimeGrid extends StatelessWidget {
  final HomeController controller;

  const TimeGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 45),
        ...List.generate(
          7,
          (index) => Expanded(
            child: DayHeader(
              label: ['월', '화', '수', '목', '금', '토', '일'][index],
              dayNum: index + 1,
            ),
          ),
        ),
      ],
    );
  }
}

class DayHeader extends StatelessWidget {
  final String label;
  final int dayNum;

  const DayHeader({super.key, required this.label, required this.dayNum});

  @override
  Widget build(BuildContext context) {
    bool isToday = dayNum == DateTime.now().weekday;
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.mainPurple
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isToday ? Colors.white : AppColors.darkPurple,
        ),
      ),
    );
  }
}

class GridLines extends StatelessWidget {
  final int hours;

  const GridLines({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        hours,
        (i) => Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.gridLine.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurrentTimeLine extends StatelessWidget {
  final HomeController controller;
  final int startHour;

  const CurrentTimeLine({
    super.key,
    required this.controller,
    required this.startHour,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final now = controller.now.value;
      if (now.hour < startHour || now.hour > controller.endHour.value) {
        return const SizedBox.shrink();
      }
      final top = ((now.hour - startHour) * 60.0) + now.minute;
      return Positioned(
        top: top,
        left: 0,
        right: 0,
        child: Container(height: 2.5, color: Colors.deepPurple),
      );
    });
  }
}
