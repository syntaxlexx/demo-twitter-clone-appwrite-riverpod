import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../models/tweet_model.dart';
import '../controller/tweet_controller.dart';
import '../widgets/tweet_card.dart';

class ReplyTweetScreen extends ConsumerWidget {
  static MaterialPageRoute route(Tweet tweet) => MaterialPageRoute(
        builder: (context) => ReplyTweetScreen(
          tweet: tweet,
        ),
      );

  final Tweet tweet;

  const ReplyTweetScreen({Key? key, required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getRepliesToTweetProvider(tweet)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = Tweet.fromMap(data.payload);

                          // check if incoming tweet repliesTo this current tweet
                          // and it doesn't exist in the current list of tweets to avoid duplication
                          if (latestTweet.repliedTo == tweet.id && !tweets.contains(latestTweet)) {
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
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: TweetCard(tweet: tweets[index]),
                              ),
                            ),
                          );
                        },
                        error: (e, st) => ErrorText(error: e.toString()),
                        loading: () {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: TweetCard(tweet: tweets[index]),
                              ),
                            ),
                          );
                        },
                      );
                },
                error: (error, st) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (value) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
            images: [],
            text: value,
            context: context,
            repliedTo: tweet.id,
            repliedToUserId: tweet.userId,
          );
        },
        decoration: const InputDecoration(hintText: 'Tweet your reply'),
      ),
    );
  }
}
