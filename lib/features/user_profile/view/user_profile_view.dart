import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../widgets/user_profile.dart';

class UserProfileView extends ConsumerWidget {
  final UserModel user;
  static MaterialPageRoute route(UserModel user) => MaterialPageRoute(builder: (context) => UserProfileView(user: user));

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: UserProfile(user: user),
    );
  }
}
