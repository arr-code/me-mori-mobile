import 'package:json_annotation/json_annotation.dart';

import 'action_card.dart';

part 'chat_turn.g.dart';

/// Wire shape for `GET /api/chat/turns?limit=N`. Server returns
/// oldest-first; each turn carries a nested `data.summary` block that
/// the controller flattens into chat-screen items on rehydrate.
@JsonSerializable()
class ChatTurn {
  final String id;
  final ChatTurnData data;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ChatTurn({
    required this.id,
    required this.data,
    required this.createdAt,
    this.updatedAt,
  });

  TurnSummary get summary => data.summary;

  factory ChatTurn.fromJson(Map<String, dynamic> json) =>
      _$ChatTurnFromJson(json);
  Map<String, dynamic> toJson() => _$ChatTurnToJson(this);
}

@JsonSerializable()
class ChatTurnData {
  final TurnSummary summary;

  const ChatTurnData({required this.summary});

  factory ChatTurnData.fromJson(Map<String, dynamic> json) =>
      _$ChatTurnDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChatTurnDataToJson(this);
}

@JsonSerializable()
class TurnSummary {
  @JsonKey(name: 'user_message')
  final String? userMessage;
  final String? reply;
  final String? intent;
  @JsonKey(name: 'pending_action')
  final PendingAction? pendingAction;
  @JsonKey(name: 'mento_status')
  final String? mentoStatus;
  @JsonKey(name: 'shown_in_chat')
  final String? shownInChat;

  const TurnSummary({
    this.userMessage,
    this.reply,
    this.intent,
    this.pendingAction,
    this.mentoStatus,
    this.shownInChat,
  });

  /// Translates the wire string into the UI status. Anything other than
  /// "accepted" / "rejected" — including null and "pending" — keeps the
  /// card in its pending shape.
  ActionCardStatus get actionStatus {
    switch (mentoStatus) {
      case 'accepted':
        return ActionCardStatus.accepted;
      case 'rejected':
        return ActionCardStatus.rejected;
      default:
        return ActionCardStatus.pending;
    }
  }

  factory TurnSummary.fromJson(Map<String, dynamic> json) =>
      _$TurnSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$TurnSummaryToJson(this);
}
