import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/apis.dart';
import '../../../models/models.dart';

final userProfileControllerProvider = StateNotifierProvider(
  (ref) => UserProfileController(
    tweetApi: ref.watch(tweetAPIProvider),
  ),
);

final getUserTweetsProvider = FutureProvider.autoDispose.family(
  (ref, String userId) => ref.watch(userProfileControllerProvider.notifier).getUserTweets(userId),
);

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetApi;

  UserProfileController({required TweetAPI tweetApi})
      : _tweetApi = tweetApi,
        super(false);

  Future<List<Tweet>> getUserTweets(String userId) async {
    final tweets = await _tweetApi.getUserTweets(userId);
    return tweets.map((e) => Tweet.fromMap(e.data)).toList();
  }
}
