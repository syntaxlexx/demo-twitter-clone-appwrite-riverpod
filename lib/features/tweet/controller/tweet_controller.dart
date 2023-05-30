import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/apis.dart';
import '../../../apis/storage_api.dart';
import '../../../core/enums/notification_type_enum.dart';
import '../../../core/enums/tweet_type_enum.dart';
import '../../../core/utils.dart';
import '../../../models/models.dart';
import '../../auth/controller/auth_controller.dart';
import '../../notifications/controller/notification_controller.dart';

final tweetControllerProvider = StateNotifierProvider.autoDispose<TweetController, bool>(
  (ref) => TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  ),
);

final getTweetsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(tweetControllerProvider.notifier).getTweets(),
);

final getLatestTweetProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(tweetAPIProvider).getLatestTweet(),
);

final getRepliesToTweetProvider = FutureProvider.autoDispose.family(
  (ref, Tweet tweet) => ref.watch(tweetControllerProvider.notifier).getRepliesToTweet(tweet),
);

final getTweetByIdProvider = FutureProvider.autoDispose.family(
  (ref, String id) => ref.watch(tweetControllerProvider.notifier).getTweetById(id),
);

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;

  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final list = await _tweetAPI.getTweets();
    return list.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<List<Tweet>> getRepliesToTweet(Tweet tweet) async {
    final list = await _tweetAPI.getRepliesToTweet(tweet);
    return list.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<Tweet> getTweetById(String id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return Tweet.fromMap(tweet.data);
  }

  Future<bool> likeTweet(Tweet tweet, UserModel user) async {
    List<String> likes = tweet.likes ?? [];

    if (tweet.likes != null && tweet.likes!.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }

    tweet = tweet.copyWith(likes: likes);

    final res = await _tweetAPI.likeTweet(tweet);

    bool isSuccess = false;

    res.fold(
      (l) => isSuccess = false,
      (r) async {
        isSuccess = true;
        await _notificationController.createNotification(
          text: '${user.name} liked your tweet',
          postId: tweet.id,
          type: NotificationType.like,
          userId: tweet.userId,
        );
      },
    );

    return isSuccess;
  }

  Future<void> reshareTweet({
    required Tweet tweet,
    required UserModel currentUser,
    required BuildContext context,
  }) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.name,
      likes: [],
      comments: [],
      resharedCount: tweet.resharedCount + 1,
    );

    final res = await _tweetAPI.updateResharedCount(tweet);

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        tweet = tweet.copyWith(
          id: ID.unique(),
          resharedCount: 0,
          tweetedAt: DateTime.now(),
        );

        final res2 = await _tweetAPI.shareTweet(tweet);
        res2.fold(
          (l) => showSnackbar(context, l.message),
          (r) async {
            showSnackbar(context, 'Retweeted');
            await _notificationController.createNotification(
              text: '${currentUser.name} retweeted your tweet',
              postId: tweet.id,
              type: NotificationType.retweet,
              userId: tweet.userId,
            );
          },
        );
      },
    );
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    String? repliedTo,
    String? repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackbar(context, 'Please enter text');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    }
  }

  Future<void> _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    String? repliedTo,
    String? repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String? link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;

    final imageLinks = await _storageAPI.uploadImages(images);

    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      userId: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      comments: const [],
      id: '',
      resharedCount: 0,
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        if (repliedToUserId != null) {
          await _notificationController.createNotification(
            text: '${user.name} replied to your tweet',
            postId: r.$id,
            type: NotificationType.reply,
            userId: repliedToUserId,
          );
        }
      },
    );
  }

  Future<void> _shareTextTweet({
    required String text,
    required BuildContext context,
    String? repliedTo,
    String? repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String? link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;

    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      userId: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      comments: const [],
      id: '',
      resharedCount: 0,
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        if (repliedToUserId != null) {
          await _notificationController.createNotification(
            text: '${user.name} replied to your tweet',
            postId: r.$id,
            type: NotificationType.reply,
            userId: repliedToUserId,
          );
        }
      },
    );
  }

  String? _getLinkFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    String? link;

    for (String word in wordsInSentence) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }

    return link;
  }

  List<String> _getHashtagsFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    List<String> hashtags = [];

    for (String word in wordsInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }

    return hashtags;
  }
}
