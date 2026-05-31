import 'package:json_annotation/json_annotation.dart';

import '../../../agenda/data/models/agenda.dart';

part 'action_card.g.dart';

/// Mirror of the backend's `pending_action.type` enum. Each variant tells
/// the controller which agenda endpoint to hit when the user accepts:
///
///   add               → POST   /api/agenda
///   addBatch          → POST   /api/agenda/batch
///   update            → PATCH  /api/agenda/:id
///   updateBatch       → PATCH  /api/agenda/batch
///   delete            → DELETE /api/agenda/:id
///   deleteBatch       → DELETE /api/agenda/batch
///   toggle            → PATCH  /api/agenda/:id/done
enum ActionType {
  @JsonValue('add_agenda')
  add,
  @JsonValue('add_agenda_batch')
  addBatch,
  @JsonValue('update_agenda')
  update,
  @JsonValue('update_agenda_batch')
  updateBatch,
  @JsonValue('delete_agenda')
  delete,
  @JsonValue('delete_agenda_batch')
  deleteBatch,
  @JsonValue('toggle_done')
  toggle,
}

extension ActionTypeX on ActionType {
  bool get isBatch => switch (this) {
        ActionType.addBatch ||
        ActionType.updateBatch ||
        ActionType.deleteBatch =>
          true,
        _ => false,
      };
}

/// User's decision on a pending turn.
///   - accept  → add the proposed agenda (keeps any colliding one too).
///   - replace → on a collision, PATCH the colliding agenda to the proposed
///               values instead (the "Ganti" button). Offered only for a
///               single `add_agenda` that collides with an existing agenda.
///   - reject  → local cancel (server reject ping only, no agenda mutation).
enum ActionDecision { accept, replace, reject }

/// Local UI status for a turn that included a `pending_action`. Server
/// doesn't persist this — it lives in the chat controller across the
/// commit round-trip.
enum ActionCardStatus { pending, accepted, rejected, replaced }

/// One item inside a batch [PendingAction]. Same field set as the
/// top-level flat shape used for single-item actions.
@JsonSerializable()
class ActionItem {
  @JsonKey(name: 'agenda_id')
  final String? agendaId;
  final String? title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final String? category;

  const ActionItem({
    this.agendaId,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.category,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) =>
      _$ActionItemFromJson(json);
  Map<String, dynamic> toJson() => _$ActionItemToJson(this);
}

/// Server-proposed mutation that the user must approve.
///
/// Two shapes coexist on the wire:
///   - Single: flat fields (`title`, `start_time`, `end_time`, `agenda_id`,
///     etc.) at the top — used for non-batch types.
///   - Batch: an `items` array — used when [type.isBatch].
///
/// `collisions` lists pre-existing agendas that overlap a proposed add
/// (only meaningful for `add_agenda`/`add_agenda_batch`).
@JsonSerializable()
class PendingAction {
  final ActionType type;

  // ── Single-item slot ────────────────────────────────────────────────
  @JsonKey(name: 'agenda_id')
  final String? agendaId;
  final String? title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final String? category;

  // ── Batch slot ──────────────────────────────────────────────────────
  @JsonKey(defaultValue: <ActionItem>[])
  final List<ActionItem> items;

  // ── Collisions (only meaningful for add_*) ──────────────────────────
  @JsonKey(defaultValue: <Agenda>[])
  final List<Agenda> collisions;

  const PendingAction({
    required this.type,
    this.agendaId,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.category,
    this.items = const [],
    this.collisions = const [],
  });

  bool get hasCollision => collisions.isNotEmpty;
  bool get isBatch => type.isBatch;

  /// Wraps the single-item flat fields as a synthetic [ActionItem]. Used
  /// by the UI to render single + batch through the same item-list path.
  ActionItem get asSingleItem => ActionItem(
        agendaId: agendaId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        category: category,
      );

  /// Effective item list for the UI, regardless of single/batch shape.
  /// Falls back to the synthetic single-item wrapper when [items] is empty.
  List<ActionItem> get effectiveItems =>
      items.isEmpty ? [asSingleItem] : items;

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    // The backend sends collision entries with `existing_*` keys (plus an
    // `item_index`), which don't match the Agenda model's id/title/start_time.
    // Left as-is, Agenda.fromJson throws and the *entire* card silently fails
    // to render. Normalize them to the Agenda shape before decoding.
    final raw = json['collisions'];
    if (raw is List &&
        raw.any((e) => e is Map && e.containsKey('existing_id'))) {
      final normalized = Map<String, dynamic>.from(json);
      normalized['collisions'] = raw.map((e) {
        if (e is Map && e.containsKey('existing_id')) {
          return <String, dynamic>{
            'id': e['existing_id'],
            'title': e['existing_title'],
            'start_time': e['existing_start'],
            'end_time': e['existing_end'],
          };
        }
        return e;
      }).toList();
      return _$PendingActionFromJson(normalized);
    }
    return _$PendingActionFromJson(json);
  }
  Map<String, dynamic> toJson() => _$PendingActionToJson(this);
}
