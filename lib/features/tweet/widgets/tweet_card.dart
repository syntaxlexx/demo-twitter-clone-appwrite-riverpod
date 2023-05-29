import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../core/enums/tweet_type_enum.dart';
import '../../../models/tweet_model.dart';
import '../../../theme/theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../../user_profile/view/user_profile_view.dart';
import '../controller/tweet_controller.dart';
import '../view/reply_tweet_screen.dart';
import 'carousel_image.dart';
import 'hashtag_text.dart';
import 'tweet_icon_button.dart';

class TweetCard extends ConsumerWidget {
  final Tweet tweet;

  const TweetCard({Key? key, required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailsProvider(tweet.userId)).when(
              data: (user) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, ReplyTweetScreen.route(tweet)),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, UserProfileView.route(user)),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic!),
                                radius: 35,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tweet.retweetedBy != null)
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsConstants.retweetIcon,
                                        color: Pallete.greyColor,
                                        height: 20,
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '${tweet.retweetedBy} retweeted',
                                        style: const TextStyle(
                                          color: Pallete.greyColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                if (tweet.repliedTo != null)
                                  ref.watch(getTweetByIdProvider(tweet.repliedTo!)).when(
                                        data: (repliedToTweet) {
                                          final replyingToUser = ref.watch(userDetailsProvider(repliedToTweet.userId)).value;

                                          return RichText(
                                            text: TextSpan(
                                                text: 'Replying to ',
                                                style: const TextStyle(
                                                  color: Pallete.greyColor,
                                                  fontSize: 16,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: ' @${replyingToUser?.name ?? '-'}',
                                                    style: const TextStyle(
                                                      color: Pallete.blueColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ]),
                                          );
                                        },
                                        error: (error, stackTrace) => ErrorText(
                                          error: error.toString(),
                                        ),
                                        loading: () => const Loader(),
                                      ),

                                // hashtags
                                HashtagText(text: tweet.text),

                                if (tweet.tweetType == TweetType.image && tweet.imageLinks != null)
                                  CarouselImage(
                                    imageLinks: tweet.imageLinks!,
                                  ),

                                if (tweet.formattedLink != null) ...[
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  AnyLinkPreview(
                                    displayDirection: UIDirection.uiDirectionHorizontal,
                                    link: tweet.formattedLink!,
                                  ),
                                ],

                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                    right: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TweetIconButton(
                                        pathName: AssetsConstants.viewsIcon,
                                        text: tweet.viewCount.toString(),
                                        onTap: () {},
                                      ),
                                      TweetIconButton(
                                        pathName: AssetsConstants.commentIcon,
                                        text: '${tweet.comments?.length ?? ''}',
                                        onTap: () {},
                                      ),
                                      TweetIconButton(
                                        pathName: AssetsConstants.retweetIcon,
                                        text: tweet.resharedCount.toString(),
                                        onTap: () {
                                          ref.read(tweetControllerProvider.notifier).reshareTweet(
                                                tweet: tweet,
                                                currentUser: currentUser,
                                                context: context,
                                              );
                                        },
                                      ),
                                      LikeButton(
                                        size: 25,
                                        likeCount: tweet.likes?.length,
                                        isLiked: tweet.likes?.contains(currentUser.uid),
                                        likeBuilder: (isLiked) {
                                          return isLiked
                                              ? SvgPicture.asset(AssetsConstants.likeFilledIcon, color: Pallete.redColor)
                                              : SvgPicture.asset(AssetsConstants.likeOutlinedIcon, color: Pallete.greyColor);
                                        },
                                        countBuilder: (likeCount, isLiked, text) => Padding(
                                          padding: const EdgeInsets.only(left: 2.0),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: isLiked ? Pallete.redColor : Pallete.greyColor,
                                            ),
                                          ),
                                        ),
                                        onTap: (isLiked) async {
                                          bool res = await ref.read(tweetControllerProvider.notifier).likeTweet(tweet, currentUser);
                                          return res ? !isLiked : isLiked;
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.share_outlined,
                                          size: 25,
                                          color: Pallete.greyColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Pallete.greyColor,
                      ),
                    ],
                  ),
                );
              },
              error: (e, st) => ErrorText(
                error: e.toString(),
              ),
              loading: () => const Loader(),
            );
  }
}
