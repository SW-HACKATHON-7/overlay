import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/enum/feedback_enum.dart';
import 'package:hackerton/core/widget/analyze_modal.dart';
import 'package:hackerton/core/widget/back_appbar.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';
import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:hackerton/presentation/analysis_result/analysis_result_notifier.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onComplete() {
    // 홈으로 이동
    context.go('/');
    // 상태 초기화
    ref.read(analysisResultNotifierProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisResultNotifierProvider);

    return BaseScaffold(
      resizeToAvoidBottomInset: true,
      appBar: BackAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopMenu(relationship: state.relationship),
          const SizedBox(height: 12),

          // 메시지 리스트
          Expanded(
            child: state.messages.isEmpty
                ? const Center(child: Text('분석 결과가 없습니다'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      if (message.speaker == 'user') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SendMessage(message: message),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReceiveMessage(message: message.text),
                        );
                      }
                    },
                  ),
          ),

          // 분석 완료하기 버튼
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: _onComplete,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: HackerTonGradients.orangeToPink,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '분석 완료하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopMenu extends StatelessWidget {
  final String relationship;

  const _TopMenu({required this.relationship});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          relationship,
          style: HackerTonTypography.MainLarge.copyWith(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: HackerTonTypography.MainSmall.copyWith(
                  color: Colors.grey,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              ShaderMask(
                shaderCallback: (bounds) =>
                    HackerTonGradients.orangeToPink.createShader(bounds),
                child: Text(
                  '실제 대화 분석 결과입니다',
                  style: HackerTonTypography.MainSmall.copyWith(fontSize: 9),
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

  const _ReceiveMessage({required this.message});

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
  final MessageDetail message;

  const _SendMessage({required this.message});

  Widget _getIcon(FeedbackIconType iconType) {
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

  FeedbackIconType _getFeedbackIcon(double? score) {
    if (score == null) return FeedbackIconType.theory;
    final intScore = score.toInt();
    if (intScore >= 95) return FeedbackIconType.best_excellent;
    if (intScore >= 90) return FeedbackIconType.excellent;
    if (intScore >= 85) return FeedbackIconType.best;
    if (intScore >= 80) return FeedbackIconType.distinguished;
    if (intScore >= 70) return FeedbackIconType.good;
    if (intScore >= 60) return FeedbackIconType.inaccurate;
    if (intScore >= 50) return FeedbackIconType.mistake;
    if (intScore >= 40) return FeedbackIconType.missed_count;
    if (intScore >= 30) return FeedbackIconType.blunder;
    return FeedbackIconType.theory;
  }

  @override
  Widget build(BuildContext context) {
    final feedbackIcon =
        message.score != null ? _getFeedbackIcon(message.score) : null;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedbackIcon != null)
              Transform.translate(
                offset: const Offset(-15, -15),
                child: InkWell(
                    onTap: () {
                      final int rating = message.score?.toInt() ?? 0;
                      final String feedBack = message.aiMessage ?? '';
                      final String suggest = message.suggestedAlternative ?? '';
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: 'Dismiss',
                        barrierColor: Colors.black54,
                        pageBuilder: (ctx, a1, a2) {
                          return AnalyzeModal(
                            rating: rating,
                            feedBack:
                                feedBack.isEmpty ? '피드백이 없습니다.' : feedBack,
                            suggest: suggest.isEmpty ? '제안이 없습니다.' : suggest,
                            isDialog: true,
                          );
                        },
                        transitionBuilder: (ctx, anim, _, child) {
                          final CurvedAnimation curved = CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          );
                          return FadeTransition(
                            opacity: curved,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1)
                                  .animate(curved),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                    child: _getIcon(feedbackIcon)),
              ),
            if (feedbackIcon != null) const SizedBox(width: 3),
            Flexible(
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
