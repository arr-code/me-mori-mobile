import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import '../../../l10n/copy_id.dart';
import '../../agenda/application/today_agenda_provider.dart';
import '../../agenda/data/agenda_repository.dart';
import '../../agenda/data/dto/agenda_requests.dart';
import '../data/chat_repository.dart';
import '../data/dto/chat_requests.dart';
import '../data/models/action_card.dart';
import 'chat_state.dart';

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  ChatRepository get _chat => ref.read(chatRepositoryProvider);
  AgendaRepository get _agenda => ref.read(agendaRepositoryProvider);

  /// Append a user message optimistically, switch the transcript into a
  /// "typing" mode, then call `POST /api/chat`. Replaces the typing
  /// indicator with the Mori reply bubble + optional action card. On
  /// failure, the typing indicator is removed and an error banner is set
  /// at the chat-screen level.
  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.sending) return;

    final now = DateTime.now();
    final userItem = UserMessageItem(
      id: 'local-${now.microsecondsSinceEpoch}',
      createdAt: now,
      text: text,
    );
    final typingItem = TypingItem(
      id: 'typing-${now.microsecondsSinceEpoch}',
      createdAt: now,
    );

    state = state.copyWith(
      items: [...state.items, userItem, typingItem],
      sending: true,
      error: null,
    );

    try {
      final turn = await _chat.send(ChatSendRequest(message: text));
      final base = _removeTrailingTyping(state.items);
      final replyTime = DateTime.now();
      // Backend may omit `turn_id` — synthesize a local id so list keys
      // stay stable. The chat controller commits actions by dispatching
      // directly to /api/agenda endpoints, so the turn_id isn't load
      // bearing for accept/reject.
      final localId = '${replyTime.microsecondsSinceEpoch}';
      final keyBase = turn.turnId ?? localId;

      final newItems = <ChatItem>[
        ...base,
        if (turn.reply.trim().isNotEmpty)
          MoriMessageItem(
            id: 'mori-$keyBase',
            createdAt: replyTime,
            text: turn.reply,
          ),
        if (turn.pendingAction != null)
          ActionCardItem(
            id: 'card-$keyBase',
            createdAt: replyTime,
            turnId: turn.turnId,
            action: turn.pendingAction!,
          ),
      ];

      state = state.copyWith(
        items: newItems,
        sending: false,
        error: null,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        items: _removeTrailingTyping(state.items),
        sending: false,
        error: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        items: _removeTrailingTyping(state.items),
        sending: false,
        error: CopyId.errNetwork,
      );
    }
  }

  /// Resolve a pending action card. Accept dispatches to the agenda
  /// endpoint matching [PendingAction.type]; reject is local-only (no
  /// server call). After a successful accept the today-agenda provider
  /// is invalidated so the home timeline reflects the mutation.
  Future<void> decide(String itemId, ActionDecision decision) async {
    final idx = state.items.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    final current = state.items[idx];
    if (current is! ActionCardItem) return;
    if (current.status != ActionCardStatus.pending) return;
    if (current.submitting) return;

    if (decision == ActionDecision.reject) {
      // Reject is purely a UI dismissal — the backend never created the
      // agenda in the first place.
      state = _replaceItem(
        idx,
        current.copyWith(status: ActionCardStatus.rejected),
      );
      return;
    }

    state = _replaceItem(idx, current.copyWith(submitting: true));

    try {
      await _commitToAgenda(current.action);
      state = _replaceItem(
        idx,
        current.copyWith(
          status: ActionCardStatus.accepted,
          submitting: false,
        ),
      );
      // Invalidate all tabs (today, thisWeek, upcoming) since Mori may
      // have committed an agenda outside today's window.
      ref.invalidate(agendaForTabProvider);
      ref.invalidate(todayAgendaProvider);
    } on AppError catch (e) {
      state = _replaceItem(idx, current.copyWith(submitting: false))
          .copyWith(error: e.message);
    } catch (_) {
      state = _replaceItem(idx, current.copyWith(submitting: false))
          .copyWith(error: CopyId.errNetwork);
    }
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(error: null);
  }

  /// Reset the conversation locally + ask the backend to drop server-side
  /// state. Backend errors are swallowed (best-effort) since the local
  /// reset has already happened.
  Future<void> restart() async {
    state = const ChatState();
    try {
      await _chat.reset();
    } catch (e) {
      if (kDebugMode) debugPrint('chat reset failed: $e');
    }
  }

  // ── Commit dispatch ──────────────────────────────────────────────────

  /// Maps a [PendingAction] to the appropriate agenda endpoint. Throws
  /// [AppError] on backend failures; throws plain [StateError] when the
  /// action shape is missing required fields the endpoint needs (e.g. an
  /// update without `agenda_id`).
  Future<void> _commitToAgenda(PendingAction action) async {
    switch (action.type) {
      case ActionType.add:
        final req = _createRequestFromItem(action.asSingleItem);
        await _agenda.create(req);
        return;
      case ActionType.addBatch:
        await _agenda.createBatch(_itemsToJsonList(action.items));
        return;
      case ActionType.update:
        final id = action.agendaId;
        if (id == null || id.isEmpty) {
          throw StateError('update_agenda tanpa agenda_id');
        }
        await _agenda.update(id, _updateRequestFromItem(action.asSingleItem));
        return;
      case ActionType.updateBatch:
        await _agenda.updateBatch(_itemsToJsonList(action.items));
        return;
      case ActionType.delete:
        final id = action.agendaId;
        if (id == null || id.isEmpty) {
          throw StateError('delete_agenda tanpa agenda_id');
        }
        await _agenda.delete(id);
        return;
      case ActionType.deleteBatch:
        final ids = action.items
            .map((i) => i.agendaId)
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toList();
        if (ids.isEmpty) {
          throw StateError('delete_agenda_batch tanpa agenda_id');
        }
        await _agenda.deleteBatch(ids);
        return;
      case ActionType.toggle:
        final id = action.agendaId;
        if (id == null || id.isEmpty) {
          throw StateError('toggle_done tanpa agenda_id');
        }
        await _agenda.toggleDone(id);
        return;
    }
  }

  CreateAgendaRequest _createRequestFromItem(ActionItem i) {
    final title = i.title;
    final startTime = i.startTime;
    // Only `title` + `start_time` are required client-side. `end_time`,
    // `description`, and `category` are backend-managed defaults when
    // omitted — chat responses don't always carry them.
    if (title == null || title.isEmpty || startTime == null) {
      throw StateError('add_agenda butuh title + start_time non-null');
    }
    return CreateAgendaRequest(
      title: title,
      description: i.description,
      startTime: startTime,
      endTime: i.endTime,
      category: i.category,
    );
  }

  UpdateAgendaRequest _updateRequestFromItem(ActionItem i) {
    return UpdateAgendaRequest(
      title: i.title,
      description: i.description,
      startTime: i.startTime,
      endTime: i.endTime,
      category: i.category,
    );
  }

  List<Map<String, dynamic>> _itemsToJsonList(List<ActionItem> items) =>
      items.map((i) => i.toJson()).toList();

  // ── helpers ──────────────────────────────────────────────────────────

  List<ChatItem> _removeTrailingTyping(List<ChatItem> src) {
    final out = List<ChatItem>.from(src);
    while (out.isNotEmpty && out.last is TypingItem) {
      out.removeLast();
    }
    return out;
  }

  ChatState _replaceItem(int index, ChatItem next) {
    final list = List<ChatItem>.from(state.items)..[index] = next;
    return state.copyWith(items: list);
  }
}
