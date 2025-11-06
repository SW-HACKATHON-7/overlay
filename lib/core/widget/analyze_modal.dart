import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/modal_frame.dart';

class AnalyzeModal extends StatelessWidget {
  final int rating;
  final String feedBack;
  final String suggest;
  final bool isDialog;

  const AnalyzeModal({
    super.key,
    required this.rating,
    required this.feedBack,
    required this.suggest,
    this.isDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('대화 분석', style: HackerTonTypography.MainLarge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        AnalysisItem(
          icon: HackerTonIcon.theory(),
          title: '피드백',
          content: feedBack,
        ),
        AnalysisItem(
          icon: HackerTonIcon.bestExcellent(),
          title: '모범 답안',
          content: suggest,
        ),
        const SizedBox(height: 12),
        GradientButton(text: '복기 종료하기', onPressed: () {}),
      ],
    );

    if (!isDialog) {
      return ModalFrame(child: content);
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 520),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(child: content),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
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
