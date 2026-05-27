import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import '../../auth/data/models/user.dart';
import 'dto/account_requests.dart';
import 'users_api.dart';

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(api: ref.watch(usersApiProvider)),
);

class UsersRepository {
  final UsersApi api;
  UsersRepository({required this.api});

  Future<User> getMe() => _run(() => api.getMe());

  Future<User> patchMe(AccountPatchRequest body) =>
      _run(() => api.patchMe(body));

  Future<User> patchPersona(PersonaPatchRequest body) =>
      _run(() => api.patchPersona(body));

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
