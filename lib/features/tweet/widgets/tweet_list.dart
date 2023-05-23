import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../models/tweet_model.dart';
import '../controller/tweet_controller.dart';
import 'tweet_card.dart';

var logger = Logger();

class TweetList extends ConsumerWidget {
  const TweetList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    if (data.events.contains('databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create')) {
                      tweets.insert(0, Tweet.fromMap(data.payload));
                    } else if (data.events.contains('databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update')) {
                      final startingPoint = data.events[0].lastIndexOf('documents.');
                      final endPoint = data.events[0].lastIndexOf('.update');
                      final tweetId = data.events[0].substring(startingPoint + 10, endPoint);

                      var tweet = tweets.where((element) => element.id == tweetId).first;
                      final tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweetId);
                      tweets.insert(tweetIndex, tweet);
                    }

                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: TweetCard(tweet: tweets[index]),
                      ),
                    );
                  },
                  error: (e, st) => ErrorText(error: e.toString()),
                  loading: () {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: TweetCard(tweet: tweets[index]),
                      ),
                    );
                  },
                );
          },
          error: (error, st) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
