import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/apis.dart';
import '../../../models/models.dart';

final exploreControllerProvider = StateNotifierProvider(
  (ref) => ExploreController(
    userApi: ref.watch(userAPIProvider),
  ),
);

final searchUserProvider = FutureProvider.autoDispose.family(
  (ref, String name) => ref.watch(exploreControllerProvider.notifier).searchUser(name),
);

class ExploreController extends StateNotifier<bool> {
  final UserAPI _userApi;

  ExploreController({required UserAPI userApi})
      : _userApi = userApi,
        super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userApi.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
