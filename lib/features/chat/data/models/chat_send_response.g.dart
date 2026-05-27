// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_send_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatTurnResponse _$ChatTurnResponseFromJson(Map<String, dynamic> json) =>
    ChatTurnResponse(
      turnId: json['turn_id'] as String?,
      reply: json['reply'] as String,
      intent: json['intent'] as String,
      pendingAction: json['pending_action'] == null
          ? null
          : PendingAction.fromJson(
              json['pending_action'] as Map<String, dynamic>),
      mentoStatus: json['mento_status'] as String?,
    );

Map<String, dynamic> _$ChatTurnResponseToJson(ChatTurnResponse instance) =>
    <String, dynamic>{
      'turn_id': instance.turnId,
      'reply': instance.reply,
      'intent': instance.intent,
      'pending_action': instance.pendingAction,
      'mento_status': instance.mentoStatus,
    };
