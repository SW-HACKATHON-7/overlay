import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/modal_frame.dart';

class AnalyzeCompleteModal extends StatelessWidget {
  const AnalyzeCompleteModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분석이 끝났습니다.',
            style: HackerTonTypography.MainLarge.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 5),
          Text(
            '자세한 분석을 보려면 대화를 클릭해주세요',
            style: HackerTonTypography.MainSmall.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 28),
          GradientButton(text: '답변 추천받기', onPressed: () {}),
          const SizedBox(height: 12),
          GradientButton(text: '복기 종료하기', onPressed: () {}),
        ],
      ),
    );
  }
}
