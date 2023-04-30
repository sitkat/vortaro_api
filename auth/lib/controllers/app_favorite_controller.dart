import 'package:auth/utils/app_response.dart';
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
}
