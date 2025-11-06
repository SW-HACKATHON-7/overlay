import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackerton/core/enum/feedback_enum.dart';
import 'package:hackerton/data/provider/api_provider.dart';
import 'package:hackerton/presentation/quiz/quiz_chat_state.dart';
import 'package:dio/dio.dart';

class QuizChatNotifier extends StateNotifier<QuizChatState> {
  final Ref ref;

  QuizChatNotifier(this.ref) : super(const QuizChatState());

  // 대화 시작
  Future<void> startConversation(String relationship) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      relationship: relationship,
    );

    try {
      final repository = ref.read(apiRepositoryProvider);
      final response = await repository.startConversation(
        relationship: relationship,
      );

      // 상대방의 첫 메시지 추가
      final messages = [
        ChatMessage(
          text: response.message,
          isUser: false,
        ),
      ];

      state = state.copyWith(
        messages: messages,
        threadId: response.threadId,
        isLoading: false,
      );
    } on DioException catch (e) {
      // 네트워크 오류 처리
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '서버 응답 시간이 초과되었습니다. 다시 시도해주세요.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      } else {
        errorMessage = '대화 시작에 실패했습니다. 다시 시도해주세요.';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    } catch (e) {
      // 기타 오류 (파싱 오류 등)
      state = state.copyWith(
        isLoading: false,
        errorMessage: '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }

  // 메시지 전송
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || state.threadId.isEmpty) return;

    // 내 메시지를 먼저 추가 (낙관적 업데이트)
    final userMessage = ChatMessage(
      text: message,
      isUser: true,
    );

    final previousMessages = state.messages; // 실패 시 롤백용

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      errorMessage: null,
    );

    try {
      final repository = ref.read(apiRepositoryProvider);
      final response = await repository.continueConversation(
        message: message,
        threadId: state.threadId,
      );

      // 피드백 아이콘 결정
      final feedbackIcon = _getFeedbackIcon(response.response.appropriatenessRating);

      // 내 메시지를 피드백 정보와 함께 업데이트
      final updatedUserMessage = userMessage.copyWith(
        feedbackIcon: feedbackIcon,
        score: response.response.appropriatenessRating,
        emotionalTone: response.response.emotionalTone,
        impactScore: response.response.impactScore,
        aiMessage: response.response.reviewComment,
        suggestedAlternative: response.response.suggestedAlternative,
      );

      // 상대방 메시지 추가
      final aiMessage = ChatMessage(
        text: response.message,
        isUser: false,
      );

      // 메시지 목록 업데이트 (마지막 메시지를 업데이트된 버전으로 교체)
      final updatedMessages = [...state.messages];
      updatedMessages[updatedMessages.length - 1] = updatedUserMessage;
      updatedMessages.add(aiMessage);

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );
    } on DioException catch (e) {
      // 네트워크 오류 처리 - 낙관적 업데이트 롤백
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '서버 응답 시간이 초과되었습니다. 다시 시도해주세요.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      } else {
        errorMessage = '메시지 전송에 실패했습니다. 다시 시도해주세요.';
      }

      state = state.copyWith(
        messages: previousMessages, // 이전 메시지로 롤백
        isLoading: false,
        errorMessage: errorMessage,
      );
    } catch (e) {
      // 기타 오류 (파싱 오류 등) - 낙관적 업데이트 롤백
      state = state.copyWith(
        messages: previousMessages, // 이전 메시지로 롤백
        isLoading: false,
        errorMessage: '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }

  // 점수에 따라 피드백 아이콘 결정
  FeedbackIconType _getFeedbackIcon(int score) {
    if (score >= 95) return FeedbackIconType.best_excellent;
    if (score >= 90) return FeedbackIconType.excellent;
    if (score >= 85) return FeedbackIconType.best;
    if (score >= 80) return FeedbackIconType.distinguished;
    if (score >= 70) return FeedbackIconType.good;
    if (score >= 60) return FeedbackIconType.inaccurate;
    if (score >= 50) return FeedbackIconType.mistake;
    if (score >= 40) return FeedbackIconType.missed_count;
    if (score >= 30) return FeedbackIconType.blunder;
    return FeedbackIconType.theory;
  }
}

// Provider
final quizChatNotifierProvider =
    StateNotifierProvider<QuizChatNotifier, QuizChatState>((ref) {
  return QuizChatNotifier(ref);
});
