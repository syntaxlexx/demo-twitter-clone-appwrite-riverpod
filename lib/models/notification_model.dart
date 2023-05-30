import 'package:equatable/equatable.dart';

import '../core/enums/notification_type_enum.dart';

class Notification extends Equatable {
  final String id;
  final String? postId;
  final String text;
  final String userId;
  final NotificationType type;

  const Notification({
    required this.id,
    this.postId,
    required this.text,
    required this.userId,
    required this.type,
  });

  Notification copyWith({
    String? id,
    String? postId,
    String? text,
    String? userId,
    NotificationType? type,
  }) {
    return Notification(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'text': text,
      'userId': userId,
      'type': type.type,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['\$id'] as String,
      postId: map['postId'] != null ? map['postId'] as String : null,
      text: map['text'] as String,
      userId: map['userId'] as String,
      type: (map['type'] as String).toNotificationTypeEnum(),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      postId,
      text,
      userId,
      type,
    ];
  }
}
