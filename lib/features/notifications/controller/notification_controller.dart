import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/notification_api.dart';
import '../../../core/enums/notification_type_enum.dart';
import '../../../models/models.dart';

final notificationControllerProvider = StateNotifierProvider<NotificationController, bool>(
  (ref) => NotificationController(
    notificationAPI: ref.watch(notificationAPIProvider),
  ),
);

final getLatestNotificationProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(notificationAPIProvider).getLatestNotification(),
);

final getNotificationsProvider = FutureProvider.autoDispose.family(
  (ref, String userId) => ref.watch(notificationControllerProvider.notifier).getNotifications(userId),
);

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;

  NotificationController({
    required NotificationAPI notificationAPI,
  })  : _notificationAPI = notificationAPI,
        super(false);

  Future<void> createNotification({
    required String text,
    String? postId,
    required NotificationType type,
    required String userId,
  }) async {
    final notification = Notification(
      id: '',
      text: text,
      userId: userId,
      type: type,
      postId: postId,
    );

    await _notificationAPI.createNotification(notification);
  }

  Future<List<Notification>> getNotifications(String userId) async {
    final notifications = await _notificationAPI.getNotifications(userId);
    return notifications.map((e) => Notification.fromMap(e.data)).toList();
  }
}
