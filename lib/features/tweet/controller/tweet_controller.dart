import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/storage_api.dart';
import '../../../apis/tweet_api.dart';
import '../../../core/enums/tweet_type_enum.dart';
import '../../../core/utils.dart';
import '../../../models/tweet_model.dart';
import '../../auth/controller/auth_controller.dart';

final tweetControllerProvider = StateNotifierProvider<TweetController, bool>(
  (ref) => TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
  ),
);

final getTweetsProvider = FutureProvider(
  (ref) => ref.watch(tweetControllerProvider.notifier).getTweets(),
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
    String link = _getLinkFromText(text);
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
      (r) => () {
        showSnackbar(context, 'Tweet Posted!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> _shareTextTweet({
    required String text,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String link = _getLinkFromText(text);
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
      (r) => () {
        showSnackbar(context, 'Tweet Posted!');
        Navigator.pop(context);
      },
    );
  }

  String _getLinkFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    String link = '';

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
