// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionItem _$ActionItemFromJson(Map<String, dynamic> json) => ActionItem(
      agendaId: json['agenda_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$ActionItemToJson(ActionItem instance) =>
    <String, dynamic>{
      'agenda_id': instance.agendaId,
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'category': instance.category,
    };

PendingAction _$PendingActionFromJson(Map<String, dynamic> json) =>
    PendingAction(
      type: $enumDecode(_$ActionTypeEnumMap, json['type']),
      agendaId: json['agenda_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      category: json['category'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      collisions: (json['collisions'] as List<dynamic>?)
              ?.map((e) => Agenda.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PendingActionToJson(PendingAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'agenda_id': instance.agendaId,
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'category': instance.category,
      'items': instance.items,
      'collisions': instance.collisions,
    };

const _$ActionTypeEnumMap = {
  ActionType.add: 'add_agenda',
  ActionType.addBatch: 'add_agenda_batch',
  ActionType.update: 'update_agenda',
  ActionType.updateBatch: 'update_agenda_batch',
  ActionType.delete: 'delete_agenda',
  ActionType.deleteBatch: 'delete_agenda_batch',
  ActionType.toggle: 'toggle_done',
};
