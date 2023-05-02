import 'dart:io';

import 'package:auth/models/favorite.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';

class AppFavoriteController extends ResourceController {
  final ManagedContext managedContext;
  AppFavoriteController(this.managedContext);

  // Получение профиля
  @Operation.get()
  Future<Response> getFavorites() async {
    try {
      // final id = AppUtils.getIdFromHeader(header);
      // final user = await managedContext.fetchObjectWithID<User>(id);
      // user?.removePropertiesFromBackingMap(
      //     [AppConst.accessToken, AppConst.refreshToken]);
      return AppResponse.ok(message: "Успешное получение избранных");
    } catch (error) {
      return AppResponse.serverError(error,
          message: "Ошибка получения избранных");
    }
  }

  @Operation.post()
  Future<Response> createFavorite(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Favorite favorite,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qCreateFavorite = Query<Favorite>(managedContext)
        ..values.user?.id = id
        ..values.word?.id = favorite.word?.id;
      await qCreateFavorite.insert();
      return AppResponse.ok(message: "Успешное добавление слова в избранные");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка добавления слова в избранные");
    }
  }
}
