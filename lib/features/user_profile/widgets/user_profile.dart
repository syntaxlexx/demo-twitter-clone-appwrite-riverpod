import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../../tweet/widgets/tweet_card.dart';
import '../controller/user_profile_controller.dart';
import '../view/edit_profile_view.dart';
import 'follow_count.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: ((context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic != null && user.bannerPic!.isNotEmpty
                            ? Image.network(
                                user.bannerPic!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Pallete.blueColor,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic!),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (currentUser.uid == user.uid) {
                              Navigator.push(context, EditProfileView.route());
                              return;
                            } else {
                              ref.read(userProfileControllerProvider.notifier).followUser(
                                    user: user,
                                    context: context,
                                    currentUser: currentUser,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                color: Pallete.whiteColor,
                                width: 1.10,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                          ),
                          child: Text(
                            currentUser.uid == user.uid
                                ? 'Edit Profile'
                                : currentUser.following != null && currentUser.following!.contains(user.uid)
                                    ? 'Unfollow'
                                    : 'Follow',
                            style: const TextStyle(
                              color: Pallete.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.isTwitterBlue)
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: SvgPicture.asset(
                                  AssetsConstants.verifiedIcon,
                                  height: 18,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '@${user.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Pallete.greyColor,
                          ),
                        ),
                        Text(
                          '${user.bio}',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Pallete.greyColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            FollowCount(count: user.following?.length ?? 0, text: 'Following'),
                            const SizedBox(
                              width: 15,
                            ),
                            FollowCount(count: user.followers?.length ?? 0, text: 'Followers'),
                          ],
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const Divider(
                          color: Pallete.whiteColor,
                        ),
                      ],
                    ),
                  ),
                )
              ];
            }),
            body: ref.watch(getUserTweetsProvider(user.uid)).when(
                  data: (tweets) {
                    // can make it realtime by copying code from twiiter_reply view
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: TweetCard(tweet: tweets[index]),
                      ),
                    );
                  },
                  error: (er, st) => ErrorText(error: er.toString()),
                  loading: () => const Loader(),
                ),
          );
  }
}
