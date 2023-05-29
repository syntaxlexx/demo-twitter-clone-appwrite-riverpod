import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../models/models.dart';
import '../controller/user_profile_controller.dart';
import '../widgets/user_profile.dart';

class UserProfileView extends ConsumerWidget {
  final UserModel user;
  static MaterialPageRoute route(UserModel user) => MaterialPageRoute(builder: (context) => UserProfileView(user: user));

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = user;

    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
            data: (data) {
              if (data.events.contains(
                'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${user.uid}.update',
              )) {
                copyOfUser = UserModel.fromMap(data.payload);
              }

              return UserProfile(user: copyOfUser);
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => UserProfile(user: copyOfUser),
          ),
    );
  }
}
