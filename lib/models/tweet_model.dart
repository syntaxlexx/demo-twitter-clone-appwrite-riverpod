import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../core/enums/tweet_type_enum.dart';

@immutable
class Tweet extends Equatable {
  final String text;
  final List<String> hashtags;
  final String? link;
  final List<String>? imageLinks;
  final String userId;
  final TweetType tweetType;
  final DateTime tweetedAt;
  final List<String>? likes;
  final List<String>? comments;
  final String id;
  final int resharedCount;
  final String? retweetedBy;
  final String? repliedTo;

  const Tweet({
    required this.text,
    required this.hashtags,
    this.link,
    this.imageLinks,
    required this.userId,
    required this.tweetType,
    required this.tweetedAt,
    this.likes,
    this.comments,
    required this.id,
    required this.resharedCount,
    this.retweetedBy,
    this.repliedTo,
  });

  int get viewCount => (comments?.length ?? 0) + resharedCount + (likes?.length ?? 0);
  String? get formattedLink => link != null
      ? link!.startsWith('https://')
          ? link
          : 'https://$link'
      : null;

  Tweet copyWith({
    String? text,
    List<String>? hashtags,
    String? link,
    List<String>? imageLinks,
    String? userId,
    TweetType? tweetType,
    DateTime? tweetedAt,
    List<String>? likes,
    List<String>? comments,
    String? id,
    int? resharedCount,
    String? retweetedBy,
    String? repliedTo,
  }) {
    return Tweet(
      text: text ?? this.text,
      hashtags: hashtags ?? this.hashtags,
      link: link ?? this.link,
      imageLinks: imageLinks ?? this.imageLinks,
      userId: userId ?? this.userId,
      tweetType: tweetType ?? this.tweetType,
      tweetedAt: tweetedAt ?? this.tweetedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      id: id ?? this.id,
      resharedCount: resharedCount ?? this.resharedCount,
      retweetedBy: retweetedBy ?? this.retweetedBy,
      repliedTo: repliedTo ?? this.repliedTo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'hashtags': hashtags,
      'link': link,
      'imageLinks': imageLinks,
      'userId': userId,
      'tweetType': tweetType.type,
      'tweetedAt': tweetedAt.millisecondsSinceEpoch,
      'likes': likes,
      'comments': comments,
      'resharedCount': resharedCount,
      'retweetedBy': retweetedBy,
      'repliedTo': repliedTo,
    };
  }

  factory Tweet.fromMap(Map<String, dynamic> map) {
    return Tweet(
      text: map['text'] as String,
      hashtags: List<String>.from(map['hashtags'] as List),
      link: map['link'] as String?,
      imageLinks: map['imageLinks'] != null ? List<String>.from(map['imageLinks'] as List) : null,
      userId: map['userId'] as String,
      tweetType: (map['tweetType'] as String).toTweetTypeEnum(),
      tweetedAt: DateTime.fromMillisecondsSinceEpoch(map['tweetedAt'] as int),
      likes: map['likes'] != null ? List<String>.from(map['likes'] as List) : null,
      comments: map['comments'] != null ? List<String>.from(map['comments'] as List) : null,
      id: map['\$id'] as String,
      resharedCount: map['resharedCount'] as int,
      retweetedBy: map['retweetedBy'] as String?,
      repliedTo: map['repliedTo'] as String?,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      text,
      hashtags,
      link,
      imageLinks,
      userId,
      tweetType,
      tweetedAt,
      likes,
      comments,
      id,
      resharedCount,
      retweetedBy,
      repliedTo,
    ];
  }
}
