import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../common/common.dart';
import '../../../core/enums/tweet_type_enum.dart';
import '../../../models/tweet_model.dart';
import '../../../theme/theme.dart';
import '../../auth/controller/auth_controller.dart';
import 'carousel_image.dart';
import 'hashtag_text.dart';

class TweetCard extends ConsumerWidget {
  final Tweet tweet;

  const TweetCard({Key? key, required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userDetailsProvider(tweet.userId)).when(
          data: (user) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePic),
                        radius: 35,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // retweeted
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: Text(
                                  '@${user.name} ${timeago.format(tweet.tweetedAt, locale: 'en_short')}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Pallete.greyColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // replied to
                          HashtagText(text: tweet.text),

                          if (tweet.tweetType == TweetType.image)
                            CarouselImage(
                              imageLinks: tweet.imageLinks,
                            ),

                          if (tweet.link.isNotEmpty) ...[
                            const SizedBox(
                              height: 4,
                            ),
                            AnyLinkPreview(
                              displayDirection: UIDirection.uiDirectionHorizontal,
                              link: tweet.link,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          error: (e, st) => ErrorText(
            error: e.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
