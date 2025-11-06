import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/widget/analyze_modal.dart';
import 'package:hackerton/core/widget/modal_frame.dart';

class RecommendComentModal extends StatelessWidget {
  const RecommendComentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalFrame(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return AnalysisItem(
            icon: HackerTonIcon.best(),
            title: '해결형 모범 답안',
            content: '“그 부분이 조금 의아했는데, 네 생각을 좀 더 듣고 싶어"라고 말해보는건 어떨까요?',
          );
        },
      ),
    );
  }
}
