import '../data/models/action_card.dart';

/// One entry in the chat transcript. Polymorphic so the UI can render
/// bubbles, the in-flight typing indicator, and action cards uniformly.
sealed class ChatItem {
  final String id;
  final DateTime createdAt;
  const ChatItem({required this.id, required this.createdAt});
}

class UserMessageItem extends ChatItem {
  final String text;
  const UserMessageItem({
    required super.id,
    required super.createdAt,
    required this.text,
  });
}

class MoriMessageItem extends ChatItem {
  final String text;
  const MoriMessageItem({
    required super.id,
    required super.createdAt,
    required this.text,
  });
}

class TypingItem extends ChatItem {
  const TypingItem({required super.id, required super.createdAt});
}

/// A turn whose Mori reply carried a `pending_action`. [turnId] is the
/// id returned from `POST /api/chat`; accept/reject endpoints address
/// the turn by this id. Nullable because some backend revisions omit it
/// — the card still renders but commit buttons are disabled.
class ActionCardItem extends ChatItem {
  final String? turnId;
  final PendingAction action;
  final ActionCardStatus status;
  final bool submitting;

  const ActionCardItem({
    required super.id,
    required super.createdAt,
    required this.turnId,
    required this.action,
    this.status = ActionCardStatus.pending,
    this.submitting = false,
  });

  ActionCardItem copyWith({
    ActionCardStatus? status,
    bool? submitting,
  }) {
    return ActionCardItem(
      id: id,
      createdAt: createdAt,
      turnId: turnId,
      action: action,
      status: status ?? this.status,
      submitting: submitting ?? this.submitting,
    );
  }
}

class ChatState {
  final List<ChatItem> items;
  final bool sending;
  final String? error;

  const ChatState({
    this.items = const [],
    this.sending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatItem>? items,
    bool? sending,
    Object? error = _sentinel,
  }) {
    return ChatState(
      items: items ?? this.items,
      sending: sending ?? this.sending,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();
}
