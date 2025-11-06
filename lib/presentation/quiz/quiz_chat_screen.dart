import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/enum/feedback_enum.dart';
import 'package:hackerton/core/widget/analyze_modal.dart';
import 'package:hackerton/core/widget/back_appbar.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';
import 'package:hackerton/presentation/quiz/quiz_chat_notifier.dart';
import 'package:hackerton/presentation/quiz/quiz_chat_state.dart';

class QuizChatScreen extends ConsumerStatefulWidget {
  final String relationship;

  const QuizChatScreen({super.key, this.relationship = '직장 상사'});

  @override
  ConsumerState<QuizChatScreen> createState() => _QuizChatScreenState();
}

class _QuizChatScreenState extends ConsumerState<QuizChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 대화 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(quizChatNotifierProvider.notifier)
          .startConversation(widget.relationship);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref.read(quizChatNotifierProvider.notifier).sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizChatNotifierProvider);

    // 메시지 개수가 변경되면 자동 스크롤
    if (state.messages.length != _previousMessageCount) {
      _previousMessageCount = state.messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    return BaseScaffold(
      resizeToAvoidBottomInset: true,
      appBar: BackAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopMenu(relationship: widget.relationship),
          const SizedBox(height: 12),

          // 에러 메시지 표시
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // 메시지 리스트
          Expanded(
            child: state.isLoading && state.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      if (message.isUser) {
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

          // 로딩 인디케이터
          if (state.isLoading && state.messages.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !state.isLoading,
                      decoration: InputDecoration(
                        hintText:
                            state.isLoading ? '메시지 전송 중...' : '메시지를 입력하세요...',
                        hintStyle: TextStyle(
                          color: state.isLoading
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: state.isLoading
                            ? Colors.grey.shade200
                            : Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      maxLength: 500,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) {
                        return null; // 글자 수 카운터 숨김
                      },
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) =>
                          state.isLoading ? null : _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: state.isLoading ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: state.isLoading
                            ? null
                            : HackerTonGradients.orangeToPink,
                        color: state.isLoading ? Colors.grey.shade300 : null,
                        shape: BoxShape.circle,
                        boxShadow: state.isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
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
                  '본 내용은 모두 가상으로 만들어 낸 상황입니다',
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
  final ChatMessage message;

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

  @override
  Widget build(BuildContext context) {
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
            if (message.feedbackIcon != null)
              Transform.translate(
                offset: const Offset(-15, -15),
                child: InkWell(
                    onTap: () {
                      final int rating = message.score ?? 0;
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
                            feedBack: feedBack.isEmpty ? '피드백이 없습니다.' : feedBack,
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
                              scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                    child: _getIcon(message.feedbackIcon!)),
              ),
            if (message.feedbackIcon != null) const SizedBox(width: 3),
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
