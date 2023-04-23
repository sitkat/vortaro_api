import 'dart:io';

import 'package:auth/models/response_model.dart' as res;
import 'package:auth/models/user.dart';
import 'package:conduit/conduit.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;
  AppAuthController(this.managedContext);

  // Авторизация
  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.username == null || user.password == null) {
      return Response.badRequest(
          body: res.ResponseModel(
              message: "Поля username и password обязательны"));
    }

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties(
            (table) => [table.id, table.salt, table.hashPassword]);
      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input("Пользователь не найден", []);
      }
      final requestHashPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");
      if (requestHashPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);
        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);
        return Response.ok(res.ResponseModel(
            data: newUser?.backing.contents, message: "Успешная авторизация"));
      } else {
        throw QueryException.input("Пароль неверный", []);
      }
    } on QueryException catch (error) {
      return Response.serverError(
          body: res.ResponseModel(message: error.message));
    }
  }

  // Регистрация
  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.username == null || user.password == null || user.email == null) {
      return Response.badRequest(
          body: res.ResponseModel(
              message: "Поля username и password обязательны"));
    }
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);
    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()["id"];
        await _updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return Response.ok(res.ResponseModel(
          data: userData?.backing.contents, message: "Успешная регистрация"));
    } on QueryException catch (error) {
      return Response.serverError(
          body: res.ResponseModel(message: error.message));
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"];
    await qUpdateTokens.updateOne();
  }

  // Обновление токена
  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    final User fetchedUser = User();

    return Response.ok(res.ResponseModel(data: {
      "id": fetchedUser.id,
      "refreshToken": fetchedUser.refreshToken,
      "accessToken": fetchedUser.accessToken,
    }, message: "Успешное обновление токенов")
        .toJson());
  }

  Map<String, dynamic> _getTokens(int id) {
    final key = Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";
    final accessClaimSet =
        JwtClaim(maxAge: Duration(hours: 1), otherClaims: {"id": id});
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
