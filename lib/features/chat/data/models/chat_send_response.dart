import 'package:json_annotation/json_annotation.dart';

import 'action_card.dart';

part 'chat_send_response.g.dart';

/// Wire shape for `POST /api/chat`. Backend produces one Mori reply per
/// request, optionally annotated with a `pending_action` the user must
/// accept or reject.
///
/// Fields that may show up but aren't load-bearing for the UI today:
///   - `mento_status`     ("pending" when there's an action awaiting)
///   - `shown_in_chat`    ("rendered" — display hint)
///   - `user_message`     (echo of what the user typed — we already
///                         appended this optimistically before send)
@JsonSerializable()
class ChatTurnResponse {
  /// Server-assigned turn id, used to address `/api/chat/turns/:id/accept`
  /// and `/reject`. Optional because not every backend revision returns
  /// it; when null we render the card without commit buttons.
  @JsonKey(name: 'turn_id')
  final String? turnId;

  final String reply;
  final String intent;

  @JsonKey(name: 'pending_action')
  final PendingAction? pendingAction;

  @JsonKey(name: 'mento_status')
  final String? mentoStatus;

  const ChatTurnResponse({
    this.turnId,
    required this.reply,
    required this.intent,
    this.pendingAction,
    this.mentoStatus,
  });

  factory ChatTurnResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatTurnResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatTurnResponseToJson(this);
}
