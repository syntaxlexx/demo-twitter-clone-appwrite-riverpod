import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../user_profile/view/user_profile_view.dart';

class SearchTile extends StatelessWidget {
  final UserModel user;

  const SearchTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, UserProfileView.route(user)),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePic!),
        radius: 30,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${user.name}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            '${user.bio}',
            style: const TextStyle(
              fontSize: 16,
              color: Pallete.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
