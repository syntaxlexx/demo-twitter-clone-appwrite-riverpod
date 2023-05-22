import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../features/tweet/widgets/tweet_list.dart';
import '../theme/pallete.dart';
import 'assets_constants.dart';

class UIConstants {
  static AppBar appbar({List<Widget>? actions}) {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        colorFilter: const ColorFilter.mode(Pallete.blueColor, BlendMode.srcIn),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  static List<Widget> bottomTabBarPages = [
    const TweetList(),
    const Text('Search Screen'),
    const Text('Notification Screen'),
  ];
}
