import 'dart:io';

import 'package:auth/models/favorite.dart';
import 'package:auth/models/user.dart';
import 'package:auth/models/word.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';

class AppFavoriteController extends ResourceController {
  final ManagedContext managedContext;
  AppFavoriteController(this.managedContext);

  //Добавление в избранные

  @Operation.post()
  Future<Response> createFavorite(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Favorite favorite,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final Word word = Word();
      word.id = favorite.idWord;
      final qCreateFavorite = Query<Favorite>(managedContext)
        ..values.user?.id = id
        ..values.word = word;
      await qCreateFavorite.insert();
      return AppResponse.ok(message: "Успешное добавление слова в избранные");
    } catch (error) {
      return AppResponse.serverError(error,
          message: "Ошибка добавления слова в избранные");
    }
  }

   // Удаление избранного слова
  @Operation.delete("id")
  Future<Response> deleteFavorite(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final favorite = await managedContext.fetchObjectWithID<Favorite>(id);
      if (favorite == null) {
        return AppResponse.badRequest(message: "Не найдено");
      }
      final qDeleteFavorite = Query<Favorite>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeleteFavorite.delete();
      return AppResponse.ok(message: "Успешное удаление слова из избранного");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления слова");
    }
  }

  // Получение избранных слов пользователя
  @Operation.get()
  Future<Response> getFavorites(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetFavorites = Query<Favorite>(managedContext)
        ..where((x) => x.user?.id).equalTo(id)
        ..returningProperties((x) => [
          x.id, x.user, x.word
        ])
        ..join(object: (x) => x.user)
        ..join(object: (x) => x.word);
      final List<Favorite> favorites = await qGetFavorites.fetch();
      // if (favorites.isEmpty) return Response.notFound();
      // if (favorites.isEmpty) return AppResponse.ok(message: "Нет избранных");
      // if (favorites.isEmpty) return Response.ok("");
      // if (favorites.isEmpty) return Response.ok(favorites);
      return Response.ok(favorites);
    } catch (error) {
      return AppResponse.serverError(error,
          message: "Ошибка получения избранных");
    }
  }
}
