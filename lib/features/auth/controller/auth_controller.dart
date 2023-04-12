import 'package:appwrite/models.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/apis.dart';
import '../../../core/utils.dart';
import '../../../models/models.dart';
import '../home/view/home_view.dart';
import '../view/login_view.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

class AuthController extends StateNotifier<bool> {
  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
      : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  Future<model.User?> currentUser() => _authAPI.currentUserAccount();

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signup(email: email, password: password);

    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        UserModel userModel = UserModel(
          email: r.email,
          name: getNameFromEmail(r.email),
          followers: const [],
          following: const [],
          profilePic: '',
          bannerPic: '',
          uid: '',
          bio: '',
          isTwitterBlue: false,
        );

        final res2 = await _userAPI.saveUserData(userModel);
        res2.fold(
          (l) => showSnackbar(context, l.message),
          (r) {
            showSnackbar(context, 'Account has been created. Please login.');
            Navigator.push(context, LoginView.route());
          },
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(email: email, password: password);

    state = false;

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) {
        showSnackbar(context, 'Account has been created. Please login.');
        Navigator.push(context, HomeView.route());
      },
    );
  }
}
