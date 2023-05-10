import 'dart:io';

import 'package:conduit_core/conduit_core.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';

import 'package:auth/models/word.dart';
import 'package:auth/models/user.dart';

class AppWordController extends ResourceController {
  final ManagedContext managedContext;
  AppWordController(this.managedContext);

  // Создание слова
  @Operation.post()
  Future<Response> createWord(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Word word,
  ) async {
    if (word.title == null ||
        word.title?.isEmpty == true ||
        word.translation == null ||
        word.translation?.isEmpty == true) {
      return AppResponse.badRequest(
          message: "Поля title и translation обязательные");
    }
    try {
      final id = AppUtils.getIdFromHeader(header);
      final logInUser = await managedContext.fetchObjectWithID<User>(id);
      if (logInUser == null) {
        return AppResponse.badRequest(message: "Неавторизованный пользователь");
      }
      final qCreateWord = Query<Word>(managedContext)
        ..values.user?.id = id
        ..values.edition = DateTime.now()
        ..values.title = word.title
        ..values.translation = word.translation
        ..values.description = word.description;
      await qCreateWord.insert();
      return AppResponse.ok(message: "Успешное создание слова");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания слова");
    }
  }

  // Обновление слова
  @Operation.put("id")
  Future<Response> updateWord(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
    @Bind.body() Word word,
  ) async {
    if (word.title == null ||
        word.title?.isEmpty == true ||
        word.translation == null ||
        word.translation?.isEmpty == true) {
      return AppResponse.badRequest(
          message: "Поля title и translation обязательные");
    }
    try {
      final idUser = AppUtils.getIdFromHeader(header);
      final fWord = await managedContext.fetchObjectWithID<Word>(id);
      if (fWord == null) {
        return AppResponse.badRequest(message: "Слово не найдено");
      }
      final qUpdateWord = Query<Word>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.user?.id = idUser
        ..values.edition = DateTime.now()
        ..values.title = word.title
        ..values.translation = word.translation
        ..values.description = word.description;
      await qUpdateWord.update();
      return AppResponse.ok(message: "Усепешное обновление слова");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка обновления слова");
    }
  }

  // Вывод слова
  @Operation.get("id")
  Future<Response> getWord(
    @Bind.path("id") int id,
  ) async {
    try {
      // final currentUserId = AppUtils.getIdFromHeader(header);
      final word = await managedContext.fetchObjectWithID<Word>(id);

      if (word == null) {
        return AppResponse.ok(message: "Слово не найдено");
      }

      // if (word.logInUser?.id != currentUserId){
      //   return AppResponse.ok(message: "Нет доступа к слову");
      // }
      // word.backing.removeProperty("user");
      word.backing.removeProperty("edition");
      // word.edition = formatDate(DateTime(word.edition), [yyyy, '-', mm,'-', dd]);

      final qGetWord = Query<Word>(managedContext)
        ..where((x) => x.id).equalTo(word.id)
        ..returningProperties((x) =>
            [x.id, x.edition, x.title, x.translation, x.description, x.user])
        ..join(object: (x) => x.user)
            .returningProperties((x) => [x.id, x.username]);
      final currentWord = await qGetWord.fetchOne();
      return Response.ok(currentWord);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения слова");
    }
  }

  // Удаление слова
  @Operation.delete("id")
  Future<Response> deleteWord(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final word = await managedContext.fetchObjectWithID<Word>(id);
      if (word == null) {
        return AppResponse.badRequest(message: "Слово не найдено");
      }
      final qDeleteWord = Query<Word>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeleteWord.delete();
      return AppResponse.ok(message: "Успешное удаление слова");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления слова");
    }
  }

  // Вывод слов
  @Operation.get()
  Future<Response> getWords(
    @Bind.query("fetchLimit") int fetchLimit,
    @Bind.query("offset") int offset,
  ) async {
    try {
      final qGetWords = Query<Word>(managedContext)
        ..fetchLimit = fetchLimit
        ..offset = offset;
      final List<Word> words = await qGetWords.fetch();
      if (words.isEmpty) return Response.notFound();
      return Response.ok(words);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения слов");
    }
  }

  //   // Вывод слов
  // @Operation.get()
  // Future<Response> getWords() async {
  //   try {
  //     final qGetWords = Query<Word>(managedContext);
  //     final List<Word> words = await qGetWords.fetch();
  //     if (words.isEmpty) return Response.notFound();
  //     return Response.ok(words);
  //   } catch (error) {
  //     return AppResponse.serverError(error, message: "Ошибка получения слов");
  //   }
  // }
}
