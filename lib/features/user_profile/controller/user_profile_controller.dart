import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/apis.dart';
import '../../../apis/storage_api.dart';
import '../../../core/enums/notification_type_enum.dart';
import '../../../core/utils.dart';
import '../../../models/models.dart';
import '../../notifications/controller/notification_controller.dart';

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>(
  (ref) => UserProfileController(
    tweetApi: ref.watch(tweetAPIProvider),
    storageApi: ref.watch(storageAPIProvider),
    userApi: ref.watch(userAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  ),
);

final getUserTweetsProvider = FutureProvider.autoDispose.family(
  (ref, String userId) => ref.watch(userProfileControllerProvider.notifier).getUserTweets(userId),
);

final getLatestUserProfileDataProvider = StreamProvider(
  (ref) => ref.watch(userAPIProvider).getLatestUserProfileData(),
);

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetApi;
  final StorageAPI _storageApi;
  final UserAPI _userApi;
  final NotificationController _notificationController;

  UserProfileController({
    required TweetAPI tweetApi,
    required StorageAPI storageApi,
    required UserAPI userApi,
    required NotificationController notificationController,
  })  : _tweetApi = tweetApi,
        _storageApi = storageApi,
        _userApi = userApi,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getUserTweets(String userId) async {
    final tweets = await _tweetApi.getUserTweets(userId);
    return tweets.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel user,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;

    if (bannerFile != null) {
      final imageUrls = await _storageApi.uploadImages([bannerFile]);
      user = user.copyWith(bannerPic: imageUrls[0]);
    }

    if (profileFile != null) {
      final imageUrls = await _storageApi.uploadImages([profileFile]);
      user = user.copyWith(profilePic: imageUrls[0]);
    }

    final res = await _userApi.udpateUserData(user);

    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }

  Future<void> followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    if (currentUser.following == null) {
      currentUser = currentUser.copyWith(following: []);
    }

    if (user.followers == null) {
      user = user.copyWith(followers: []);
    }

    // if is currently following user, unfollow
    if (currentUser.following!.contains(user.uid)) {
      user.followers!.remove(currentUser.uid);
      currentUser.following!.remove(user.uid);
    } else {
      user.followers!.add(currentUser.uid);
      currentUser.following!.add(user.uid);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);

    final res = await _userApi.followUser(user);
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        final res2 = await _userApi.addToFollowing(currentUser);

        res2.fold(
          (l) => showSnackbar(context, l.message),
          (r) async {
            await _notificationController.createNotification(
              text: '${currentUser.name} followed you',
              type: NotificationType.follow,
              userId: user.uid,
            );
          },
        );
      },
    );
  }
}
