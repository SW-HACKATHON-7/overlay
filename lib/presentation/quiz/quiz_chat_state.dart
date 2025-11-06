import 'package:hackerton/core/enum/feedback_enum.dart';

class QuizChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String threadId;
  final String relationship;
  final String? errorMessage;

  const QuizChatState({
    this.messages = const [],
    this.isLoading = false,
    this.threadId = '',
    this.relationship = '',
    this.errorMessage,
  });

  QuizChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? threadId,
    String? relationship,
    String? errorMessage,
  }) {
    return QuizChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      threadId: threadId ?? this.threadId,
      relationship: relationship ?? this.relationship,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser; // true면 내가 보낸 메시지, false면 상대방 메시지
  final FeedbackIconType? feedbackIcon;
  final int? score;
  final String? emotionalTone;
  final int? impactScore;
  final String? aiMessage;
  final String? suggestedAlternative;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.feedbackIcon,
    this.score,
    this.emotionalTone,
    this.impactScore,
    this.aiMessage,
    this.suggestedAlternative,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    FeedbackIconType? feedbackIcon,
    int? score,
    String? emotionalTone,
    int? impactScore,
    String? aiMessage,
    String? suggestedAlternative,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      feedbackIcon: feedbackIcon ?? this.feedbackIcon,
      score: score ?? this.score,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      impactScore: impactScore ?? this.impactScore,
      aiMessage: aiMessage ?? this.aiMessage,
      suggestedAlternative: suggestedAlternative ?? this.suggestedAlternative,
    );
  }
}
