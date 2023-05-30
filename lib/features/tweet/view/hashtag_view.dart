import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../controller/tweet_controller.dart';
import '../widgets/tweet_card.dart';

class HashtagView extends ConsumerWidget {
  final String hashtag;

  const HashtagView({Key? key, required this.hashtag}) : super(key: key);

  static MaterialPageRoute route(hashtag) => MaterialPageRoute(builder: (context) => HashtagView(hashtag: hashtag));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hashtag),
        centerTitle: true,
      ),
      body: ref.watch(getTweetByHashtagProvider(hashtag)).when(
            data: (tweets) {
              return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: TweetCard(tweet: tweets[index]),
                ),
              );
            },
            error: (error, st) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
