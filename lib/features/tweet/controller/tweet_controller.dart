import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/storage_api.dart';
import '../../../apis/tweet_api.dart';
import '../../../core/enums/tweet_type_enum.dart';
import '../../../core/utils.dart';
import '../../../models/models.dart';
import '../../../models/tweet_model.dart';
import '../../auth/controller/auth_controller.dart';

final tweetControllerProvider = StateNotifierProvider.autoDispose<TweetController, bool>(
  (ref) => TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
  ),
);

final getTweetsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(tweetControllerProvider.notifier).getTweets(),
);

final getLatestTweetProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(tweetAPIProvider).getLatestTweet(),
);

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;

  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final list = await _tweetAPI.getTweets();
    return list.map((tweet) => Tweet.fromMap(tweet.data)).toList();
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
      (r) => isSuccess = true,
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
          (r) => showSnackbar(context, 'Retweeted'),
        );
      },
    );
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
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
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
      );
    }
  }

  Future<void> _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
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
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => null,
    );
  }

  Future<void> _shareTextTweet({
    required String text,
    required BuildContext context,
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
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => null,
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
