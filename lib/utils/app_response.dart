import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:auth/models/response_model.dart' as r;

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static r.ResponseModel _getResponseModel(error, String? message) {
    if (error is QueryException) {
      return r.ResponseModel(
          error: error.toString(), message: message ?? error.message);
    }
    if (error is JwtException) {
      return r.ResponseModel(
          error: error.toString(), message: message ?? error.message);
    }
    return r.ResponseModel(
        error: error.toString(), message: message ?? "Неизвестная ошибка");
  }

  AppResponse.ok({dynamic body, String? message})
      : super.ok(r.ResponseModel(data: body, message: message));
}
