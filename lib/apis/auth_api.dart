import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import '../core/core.dart';

final authAPIProvider = Provider((ref) {
  return AuthAPI(account: ref.watch(appwriteAccountProvider));
});

abstract class IAuthAPI {
  FutureEither<model.User> signup({
    required String email,
    required String password,
  });

  FutureEither<model.Session> login({
    required String email,
    required String password,
  });

  Future<model.User?> currentUserAccount();
  FutureEitherVoid logout();
}

class AuthAPI implements IAuthAPI {
  final Account _account;
  var logger = Logger();

  AuthAPI({required Account account}) : _account = account;

  @override
  FutureEither<model.User> signup({required String email, required String password}) async {
    try {
      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      logger.e(e);

      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }

  @override
  FutureEither<model.Session> login({required String email, required String password}) async {
    try {
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );

      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }

  @override
  Future<model.User?> currentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEitherVoid logout() async {
    try {
      await _account.deleteSession(
        sessionId: 'current',
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }
}
