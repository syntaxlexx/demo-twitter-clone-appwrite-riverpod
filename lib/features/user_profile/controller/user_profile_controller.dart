import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/apis.dart';
import '../../../apis/storage_api.dart';
import '../../../core/utils.dart';
import '../../../models/models.dart';

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>(
  (ref) => UserProfileController(
    tweetApi: ref.watch(tweetAPIProvider),
    storageApi: ref.watch(storageAPIProvider),
    userApi: ref.watch(userAPIProvider),
  ),
);

final getUserTweetsProvider = FutureProvider.autoDispose.family(
  (ref, String userId) => ref.watch(userProfileControllerProvider.notifier).getUserTweets(userId),
);

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetApi;
  final StorageAPI _storageApi;
  final UserAPI _userApi;

  UserProfileController({
    required TweetAPI tweetApi,
    required StorageAPI storageApi,
    required UserAPI userApi,
  })  : _tweetApi = tweetApi,
        _storageApi = storageApi,
        _userApi = userApi,
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
}
