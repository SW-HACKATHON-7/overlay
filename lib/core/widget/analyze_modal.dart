import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/modal_frame.dart';

class AnalyzeModal extends StatelessWidget {
  const AnalyzeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalFrame(
      child: Column(
        spacing: 16,
        children: [
          AnalysisItem(
            icon: HackerTonIcon.blunder(),
            title: '블런더',
            content: '네 그래서 어제 올리진 못했죠',
          ),
          AnalysisItem(
            icon: HackerTonIcon.theory(),
            title: '피드백',
            content: '이 답변 이후 분위기가 안좋아졌어요 다소 공격적으로 들릴 수 있어요',
          ),
          AnalysisItem(
            icon: HackerTonIcon.bestExcellent(),
            title: '모범 답안',
            content: '"그 부분이 조금 의아했는데, 네 생각을 좀 더 듣고 싶어요" 라고 말했으면 좋았을 것 같아요',
          ),
          const SizedBox(height: 12),
          GradientButton(text: '복기 종료하기', onPressed: () {}),
        ],
      ),
    );
  }
}

class AnalysisItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String content;

  const AnalysisItem({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            icon,
            const SizedBox(width: 7),
            Text(title, style: HackerTonTypography.MainLarge),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: HackerTonTypography.MainSmall.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
