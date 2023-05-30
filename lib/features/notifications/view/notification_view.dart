import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../../contants/constants.dart';
import '../../../models/models.dart' as model;
import '../../auth/controller/auth_controller.dart';
import '../controller/notification_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uid)).when(
                data: (notifications) {
                  return ref.watch(getLatestNotificationProvider).when(
                        data: (data) {
                          if (data.events.contains('databases.*.collections.${AppwriteConstants.notificationsCollection}.documents.*.create')) {
                            final latest = model.Notification.fromMap(data.payload);
                            if (latest.userId == currentUser.uid) {
                              notifications.insert(0, model.Notification.fromMap(data.payload));
                            }
                          }

                          return ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: NotificationTile(notification: notifications[index]),
                            ),
                          );
                        },
                        error: (e, st) => ErrorText(error: e.toString()),
                        loading: () {
                          return ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: NotificationTile(notification: notifications[index]),
                            ),
                          );
                        },
                      );
                },
                error: (error, st) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
    );
  }
}
