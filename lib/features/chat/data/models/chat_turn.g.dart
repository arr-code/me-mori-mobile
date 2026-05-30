// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_turn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatTurn _$ChatTurnFromJson(Map<String, dynamic> json) => ChatTurn(
      id: json['id'] as String,
      data: ChatTurnData.fromJson(json['data'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChatTurnToJson(ChatTurn instance) => <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

ChatTurnData _$ChatTurnDataFromJson(Map<String, dynamic> json) => ChatTurnData(
      summary: TurnSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatTurnDataToJson(ChatTurnData instance) =>
    <String, dynamic>{
      'summary': instance.summary,
    };

TurnSummary _$TurnSummaryFromJson(Map<String, dynamic> json) => TurnSummary(
      userMessage: json['user_message'] as String?,
      reply: json['reply'] as String?,
      intent: json['intent'] as String?,
      pendingAction: json['pending_action'] == null
          ? null
          : PendingAction.fromJson(
              json['pending_action'] as Map<String, dynamic>),
      mentoStatus: json['mento_status'] as String?,
      shownInChat: json['shown_in_chat'] as String?,
    );

Map<String, dynamic> _$TurnSummaryToJson(TurnSummary instance) =>
    <String, dynamic>{
      'user_message': instance.userMessage,
      'reply': instance.reply,
      'intent': instance.intent,
      'pending_action': instance.pendingAction,
      'mento_status': instance.mentoStatus,
      'shown_in_chat': instance.shownInChat,
    };
