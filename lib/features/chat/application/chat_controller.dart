import 'dart:async';

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
import '../data/models/chat_turn.dart';
import 'chat_state.dart';

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  ChatRepository get _chat => ref.read(chatRepositoryProvider);
  AgendaRepository get _agenda => ref.read(agendaRepositoryProvider);

  /// Hydrate the transcript from `GET /api/chat/turns?limit=N` — called
  /// once when the chat screen mounts. Existing in-memory items are
  /// replaced. Failures set `state.error`; the user can retry by tapping
  /// "↻ ulangi" or pulling to refresh.
  Future<void> loadHistory({int limit = 50}) async {
    state = state.copyWith(sending: false, error: null);
    try {
      final turns = await _chat.getHistory(limit: limit);
      state = state.copyWith(
        items: _itemsFromTurns(turns),
        error: null,
      );
    } on AppError catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: CopyId.errNetwork);
    }
  }

  /// Append a user message optimistically, switch the transcript into a
  /// "typing" mode, then call `POST /api/chat`. Replaces the typing
  /// indicator with the Mori reply bubble + optional action card. Fires
  /// `/turns/:id/seen` once the turn lands so the backend doesn't
  /// resurface it on next reload.
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
      final keyBase = turn.turnId ?? '${replyTime.microsecondsSinceEpoch}';

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

      // Lifecycle ping — fire-and-forget so a transient failure doesn't
      // block the chat. Backend may not always echo the turn_id, in
      // which case we skip the call.
      final tid = turn.turnId;
      if (tid != null && tid.isNotEmpty) {
        unawaited(_markSeenSilently(tid));
      }
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

  /// Resolve a pending action card.
  ///
  /// Accept ordering, per backend contract:
  ///   1. Execute the agenda mutation (`/api/agenda*`) — frontend owns
  ///      this; backend won't do it implicitly.
  ///   2. `POST /api/chat/turns/:id/accept` to flip server `mento_status`.
  ///   3. Flip local UI to accepted + invalidate agenda providers.
  /// If step 1 fails the user sees an error and the card stays pending;
  /// if step 2 fails we still mark accepted locally (agenda already
  /// landed) and surface a muted error.
  ///
  /// Reject: server call only, no agenda mutation.
  Future<void> decide(String itemId, ActionDecision decision) async {
    final idx = state.items.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    final current = state.items[idx];
    if (current is! ActionCardItem) return;
    if (current.status != ActionCardStatus.pending) return;
    if (current.submitting) return;

    state = _replaceItem(idx, current.copyWith(submitting: true));

    try {
      if (decision == ActionDecision.reject) {
        final tid = current.turnId;
        if (tid != null && tid.isNotEmpty) {
          await _chat.rejectTurn(tid);
        }
        state = _replaceItem(
          idx,
          current.copyWith(
            status: ActionCardStatus.rejected,
            submitting: false,
          ),
        );
        return;
      }

      // Accept or Replace: agenda mutation first, then mark resolved
      // server-side. Replace ("Ganti") PATCHes the colliding agenda to the
      // proposed values instead of adding a new one.
      final ActionCardStatus resolvedStatus;
      if (decision == ActionDecision.replace) {
        await _commitReplace(current.action);
        resolvedStatus = ActionCardStatus.replaced;
      } else {
        await _commitToAgenda(current.action);
        resolvedStatus = ActionCardStatus.accepted;
      }

      final tid = current.turnId;
      if (tid != null && tid.isNotEmpty) {
        try {
          await _chat.acceptTurn(tid);
        } on AppError catch (e) {
          // Agenda already committed — log/surface but keep resolved.
          if (kDebugMode) debugPrint('accept ping failed: ${e.message}');
        } catch (e) {
          if (kDebugMode) debugPrint('accept ping failed: $e');
        }
      }

      state = _replaceItem(
        idx,
        current.copyWith(
          status: resolvedStatus,
          submitting: false,
        ),
      );
      // Invalidate all tabs since Mori may have written outside today's
      // window.
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

  Future<void> _markSeenSilently(String turnId) async {
    try {
      await _chat.markSeen(turnId);
    } catch (e) {
      if (kDebugMode) debugPrint('seen ping failed: $e');
    }
  }

  // ── History → ChatItem flattening ────────────────────────────────────

  List<ChatItem> _itemsFromTurns(List<ChatTurn> turns) {
    final out = <ChatItem>[];
    for (final t in turns) {
      final s = t.summary;
      final when = t.createdAt;
      if ((s.userMessage ?? '').trim().isNotEmpty) {
        out.add(UserMessageItem(
          id: 'user-${t.id}',
          createdAt: when,
          text: s.userMessage!,
        ));
      }
      if ((s.reply ?? '').trim().isNotEmpty) {
        out.add(MoriMessageItem(
          id: 'mori-${t.id}',
          createdAt: when,
          text: s.reply!,
        ));
      }
      final action = s.pendingAction;
      if (action != null) {
        out.add(ActionCardItem(
          id: 'card-${t.id}',
          createdAt: when,
          turnId: t.id,
          action: action,
          status: s.actionStatus,
        ));
      }
    }
    return out;
  }

  // ── Commit dispatch ──────────────────────────────────────────────────

  Future<void> _commitToAgenda(PendingAction action) async {
    switch (action.type) {
      case ActionType.add:
        await _agenda.create(_createRequestFromItem(action.asSingleItem));
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

  /// "Ganti" (replace): PATCH the colliding agenda to the proposed values
  /// instead of creating a new one. Only valid for a single add that carries
  /// a collision with a known agenda id.
  Future<void> _commitReplace(PendingAction action) async {
    final id =
        action.collisions.isNotEmpty ? action.collisions.first.id : null;
    if (id == null || id.isEmpty) {
      throw StateError('Ganti tanpa agenda bentrok');
    }
    await _agenda.update(id, _updateRequestFromItem(action.asSingleItem));
  }

  CreateAgendaRequest _createRequestFromItem(ActionItem i) {
    final title = i.title;
    final startTime = i.startTime;
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
