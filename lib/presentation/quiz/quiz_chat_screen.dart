import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/enum/feedback_enum.dart';
import 'package:hackerton/core/widget/back_appbar.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';

class QuizChatScreen extends StatelessWidget {
  const QuizChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: BackAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopMenu(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _ReceiveMessage(
                  message: '안녕하세요 홍길동 담당자님\n어제 서비스 홍보글이 왜 SNS에 올라오지 않았는지 의문입니다',
                ),
                const SizedBox(height: 12),
                _SendMessage(
                  message: '수정 요청 오길래 기다렸습니다',
                  iconType: FeedbackIconType.mistake,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopMenu extends StatelessWidget {
  const _TopMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '직장 상사',
          style: HackerTonTypography.MainLarge.copyWith(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 25),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '2025년 11월 5일 9:41',
                style: HackerTonTypography.MainSmall.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) =>
                    HackerTonGradients.orangeToPink.createShader(bounds),
                child: Text(
                  '본 내용은 모두 가상으로 만들어 낸 상황입니다',
                  style: HackerTonTypography.MainSmall.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiveMessage extends StatelessWidget {
  final String message;

  const _ReceiveMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: HackerTonGradients.orangeToPink,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              message,
              style: HackerTonTypography.MainSmall.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendMessage extends StatelessWidget {
  final String message;
  final FeedbackIconType iconType;

  const _SendMessage({
    super.key,
    required this.message,
    required this.iconType,
  });

  Widget _getIcon() {
    // _getIcon() 메서드는 기존과 동일합니다.
    switch (iconType) {
      case FeedbackIconType.best_excellent:
        return HackerTonIcon.bestExcellent();
      case FeedbackIconType.excellent:
        return HackerTonIcon.excellent();
      case FeedbackIconType.best:
        return HackerTonIcon.best();
      case FeedbackIconType.distinguished:
        return HackerTonIcon.distinguished();
      case FeedbackIconType.good:
        return HackerTonIcon.good();
      case FeedbackIconType.inaccurate:
        return HackerTonIcon.inaccurate();
      case FeedbackIconType.mistake:
        return HackerTonIcon.mistake();
      case FeedbackIconType.missed_count:
        return HackerTonIcon.missedCount();
      case FeedbackIconType.blunder:
        return HackerTonIcon.blunder();
      case FeedbackIconType.theory:
        return HackerTonIcon.theory();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Align 위젯으로 감싸서 오른쪽 정렬
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        // 2. 이 alignment 속성은 더 이상 필요 없으므로 제거
        // alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: HackerTonColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 자식 크기만큼만 차지
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(-15, -15), // 위로 2픽셀 이동
              child: _getIcon(),
            ),
            const SizedBox(width: 3),
            // 3. Flexible로 Text를 감싸서 긴 텍스트 줄바꿈 처리
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
