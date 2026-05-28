import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import 'academy_detail_controller.dart';

class AcademyDetailPayment {
  // 결제 주기 선택 행
  static Widget cycleRow(AcademyDetailController ctrl, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '결제 주기',
              style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.w600),
            ),
          ),
          if (isEditing)
            Expanded(
              child: Wrap(
                spacing: 9,
                children: ctrl.cycles.map((c) {
                  return GestureDetector(
                    onTap: () => ctrl.selectedCycle.value = c,
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ctrl.selectedCycle.value == c
                            ? AppColors.mainPurple
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mainPurple),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          color: ctrl.selectedCycle.value == c
                              ? Colors.white
                              : AppColors.darkPurple,
                          fontSize: 13,
                        ),
                      ),
                    )),
                  );
                }).toList(),
              ),
            )
          else
            Obx(() => Text(
              ctrl.selectedCycle.value,
              style: const TextStyle(color: AppColors.darkPurple),
            )),
        ],
      ),
    );
  }

  // 결제일 선택 행 (주기에 따라 다른 UI)
  static Widget paymentDayRow(AcademyDetailController ctrl, bool isEditing) {
    return Obx(() {
      final cycle = ctrl.selectedCycle.value;

      // 주간: 요일 선택
      if (cycle == '주간') {
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '결제 요일',
                  style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.w600),
                ),
              ),
              if (isEditing)
                Expanded(
                  child: Wrap(
                    spacing: 5,
                    children: List.generate(7, (i) {
                      return GestureDetector(
                        onTap: () => ctrl.paymentDay.value = i + 1,
                        child: Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ctrl.paymentDay.value == i + 1
                                ? AppColors.mainPurple
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.mainPurple),
                          ),
                          child: Text(
                            weekdays[i],
                            style: TextStyle(
                              color: ctrl.paymentDay.value == i + 1
                                  ? Colors.white
                                  : AppColors.darkPurple,
                              fontSize: 13,
                            ),
                          ),
                        )),
                      );
                    }),
                  ),
                )
              else
                Text(
                  ['월', '화', '수', '목', '금', '토', '일'][ctrl.paymentDay.value - 1],
                  style: const TextStyle(color: AppColors.darkPurple),
                ),
            ],
          ),
        );
      }

      // 분기/반기/연간: 시작월 + 일 선택
      if (cycle == '분기' || cycle == '반기' || cycle == '연간') {
        return Column(
          children: [
            // 시작월 슬라이더
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      '시작 월',
                      style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isEditing)
                    Expanded(
                      child: Obx(() => Column(
                        children: [
                          Slider(
                            value: ctrl.paymentStartMonth.value.toDouble(),
                            min: 1,
                            max: 12,
                            divisions: 11,
                            activeColor: AppColors.mainPurple,
                            label: '${ctrl.paymentStartMonth.value}월',
                            onChanged: (v) => ctrl.paymentStartMonth.value = v.toInt(),
                          ),
                          Text('${ctrl.paymentStartMonth.value}월',
                              style: const TextStyle(color: AppColors.darkPurple)),
                        ],
                      )),
                    )
                  else
                    Text('${ctrl.paymentStartMonth.value}월',
                        style: const TextStyle(color: AppColors.darkPurple)),
                ],
              ),
            ),
            // 결제일 슬라이더
            _daySlider(ctrl, isEditing),
          ],
        );
      }

      // 월간: 1일~31일 슬라이더
      return _daySlider(ctrl, isEditing);
    });
  }

  // 결제일 슬라이더 (월간/분기/반기/연간 공통)
  static Widget _daySlider(AcademyDetailController ctrl, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '결제일',
              style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.w600),
            ),
          ),
          if (isEditing)
            Expanded(
              child: Obx(() => Column(
                children: [
                  Slider(
                    value: ctrl.paymentDay.value.toDouble(),
                    min: 1,
                    max: 31,
                    divisions: 30,
                    activeColor: AppColors.mainPurple,
                    label: '${ctrl.paymentDay.value}일',
                    onChanged: (v) => ctrl.paymentDay.value = v.toInt(),
                  ),
                  Text('${ctrl.paymentDay.value}일',
                      style: const TextStyle(color: AppColors.darkPurple)),
                ],
              )),
            )
          else
            Obx(() => Text('${ctrl.paymentDay.value}일',
                style: const TextStyle(color: AppColors.darkPurple))),
        ],
      ),
    );
  }

  // 결제 알림 행
  static Widget alarmRow(AcademyDetailController ctrl, bool isEditing) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '결제 알림',
                  style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.w600),
                ),
              ),
              Obx(() => Switch(
                value: ctrl.paymentAlarm.value,
                activeColor: AppColors.mainPurple,
                onChanged: isEditing ? (v) => ctrl.paymentAlarm.value = v : null,
              )),
              Obx(() {
                if (!ctrl.paymentAlarm.value) return const SizedBox.shrink();
                return isEditing
                    ? DropdownButton<int>(
                        value: ctrl.paymentAlarmDays.value,
                        items: List.generate(7, (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d일 전')))
                            .toList(),
                        onChanged: (v) => ctrl.paymentAlarmDays.value = v!,
                      )
                    : Text('${ctrl.paymentAlarmDays.value}일 전',
                        style: const TextStyle(color: AppColors.darkPurple));
              }),
            ],
          ),
        ),
        // 알림 시간 선택
        Obx(() {
          if (!ctrl.paymentAlarm.value) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    '알림 시간',
                    style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isEditing)
                  Row(
                    children: [
                      Obx(() => DropdownButton<int>(
                        value: ctrl.paymentAlarmHour.value,
                        items: List.generate(24, (i) => i)
                            .map((h) => DropdownMenuItem(value: h, child: Text('$h시')))
                            .toList(),
                        onChanged: (v) => ctrl.paymentAlarmHour.value = v!,
                      )),
                      const SizedBox(width: 8),
                      Obx(() => DropdownButton<int>(
                        value: ctrl.paymentAlarmMinute.value,
                        items: [0, 10, 20, 30, 40, 50]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m분')))
                            .toList(),
                        onChanged: (v) => ctrl.paymentAlarmMinute.value = v!,
                      )),
                    ],
                  )
                else
                  Obx(() => Text(
                    '${ctrl.paymentAlarmHour.value}시 ${ctrl.paymentAlarmMinute.value.toString().padLeft(2, '0')}분',
                    style: const TextStyle(color: AppColors.darkPurple),
                  )),
              ],
            ),
          );
        }),
      ],
    );
  }
}
