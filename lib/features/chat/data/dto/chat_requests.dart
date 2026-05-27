import 'package:json_annotation/json_annotation.dart';

part 'chat_requests.g.dart';

@JsonSerializable(createFactory: false)
class ChatSendRequest {
  final String message;

  const ChatSendRequest({required this.message});

  Map<String, dynamic> toJson() => _$ChatSendRequestToJson(this);
}
