import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/common.dart';
import '../../../../theme/theme.dart';
import '../../../user_profile/controller/user_profile_controller.dart';
import '../../../user_profile/view/user_profile_view.dart';
import '../../controller/auth_controller.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return SafeArea(
      child: Drawer(
        backgroundColor: Pallete.backgroundColor,
        child: currentUser == null
            ? const Loader()
            : Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, UserProfileView.route(currentUser));
                    },
                    leading: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                    title: const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      ref.read(userProfileControllerProvider.notifier).updateUserProfile(
                            user: currentUser.copyWith(isTwitterBlue: !currentUser.isTwitterBlue),
                            context: context,
                          );
                    },
                    leading: const Icon(
                      Icons.payment,
                      size: 30,
                    ),
                    title: const Text(
                      'Twitter Blue',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => ref.read(authControllerProvider.notifier).logout(context),
                    leading: const Icon(
                      Icons.logout,
                      size: 30,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
