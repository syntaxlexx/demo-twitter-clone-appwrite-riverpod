import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../core/enums/tweet_type_enum.dart';

@immutable
class Tweet extends Equatable {
  final String text;
  final List<String> hashtags;
  final String link;
  final List<String> imageLinks;
  final String userId;
  final TweetType tweetType;
  final DateTime tweetedAt;
  final List<String> likes;
  final List<String> comments;
  final String id;
  final int resharedCount;

  const Tweet({
    required this.text,
    required this.hashtags,
    required this.link,
    required this.imageLinks,
    required this.userId,
    required this.tweetType,
    required this.tweetedAt,
    required this.likes,
    required this.comments,
    required this.id,
    required this.resharedCount,
  });

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
    };
  }

  factory Tweet.fromMap(Map<String, dynamic> map) {
    return Tweet(
      text: map['text'] as String,
      hashtags: List<String>.from(map['hashtags'] as List),
      link: map['link'] as String,
      imageLinks: List<String>.from(map['imageLinks'] as List),
      userId: map['userId'] as String,
      tweetType: (map['tweetType'] as String).toTweetTypeEnum(),
      tweetedAt: DateTime.fromMillisecondsSinceEpoch(map['tweetedAt'] as int),
      likes: List<String>.from(map['likes'] as List),
      comments: List<String>.from(map['comments'] as List),
      id: map['\$id'] as String,
      resharedCount: map['resharedCount'] as int,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
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
    ];
  }
}
