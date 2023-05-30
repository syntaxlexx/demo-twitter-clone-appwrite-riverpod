import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../contants/assets_constants.dart';
import '../../../core/enums/notification_type_enum.dart';
import '../../../models/models.dart' as model;
import '../../../theme/theme.dart';

class NotificationTile extends StatelessWidget {
  final model.Notification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: getIcon(),
      title: Text(notification.text),
    );
  }

  Widget getIcon() {
    switch (notification.type) {
      case NotificationType.follow:
        return const Icon(Icons.person, color: Pallete.blueColor);

      case NotificationType.like:
        return SvgPicture.asset(
          AssetsConstants.likeFilledIcon,
          color: Pallete.redColor,
          height: 20,
        );
      case NotificationType.retweet:
        return SvgPicture.asset(
          AssetsConstants.retweetIcon,
          color: Pallete.whiteColor,
          height: 20,
        );
      case NotificationType.reply:
        return const Icon(Icons.comment, color: Pallete.whiteColor);
      default:
        return const Icon(Icons.info, color: Pallete.blueColor);
    }
  }
}
