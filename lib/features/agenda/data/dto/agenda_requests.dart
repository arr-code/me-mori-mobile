import 'package:json_annotation/json_annotation.dart';

part 'agenda_requests.g.dart';

@JsonSerializable(includeIfNull: false, createFactory: false)
class CreateAgendaRequest {
  final String title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  // Nullable: backend computes/defaults end_time when omitted — chat
  // responses don't always carry it.
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final String? category;

  const CreateAgendaRequest({
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.category,
  });

  Map<String, dynamic> toJson() => _$CreateAgendaRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, createFactory: false)
class UpdateAgendaRequest {
  final String? title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final String? category;
  @JsonKey(name: 'is_done')
  final bool? isDone;

  const UpdateAgendaRequest({
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.category,
    this.isDone,
  });

  Map<String, dynamic> toJson() => _$UpdateAgendaRequestToJson(this);
}
