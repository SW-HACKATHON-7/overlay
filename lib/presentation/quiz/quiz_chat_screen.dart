import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
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
      // ensure clean state on enter
      ref.read(quizChatNotifierProvider.notifier).resetState();
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
          if (state.errorMessage != null) ...[
            // 에러박스 그대로
          ],
          Expanded(
            child: state.isLoading && state.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (_, index) {
                      final msg = state.messages[index];
                      return msg.isUser
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SendMessage(message: msg),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ReceiveMessage(message: msg.text),
                            );
                    },
                  ),
          ),
          if (state.isLoading && state.messages.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      btn: Container(
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  hintText: state.isLoading ? '메시지 전송 중...' : '메시지를 입력하세요...',
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
                onSubmitted: (_) => state.isLoading ? null : _sendMessage(),
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
                  gradient:
                      state.isLoading ? null : HackerTonGradients.orangeToPink,
                  color: state.isLoading ? Colors.grey.shade300 : null,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
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

  Widget _getIcon(int rating) {
    return HackerTonIcon.appropriatenessScore(rating, width: 28, height: 28);
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
            if (message.score != null)
              Transform.translate(
                offset: const Offset(-15, -15),
                child: _getIcon(message.impactScore!),
              ),
            if (message.score != null) const SizedBox(width: 3),
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
