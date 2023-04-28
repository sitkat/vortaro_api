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
        ..returningProperties((x) => [
          x.id,
          x.edition,
          x.title,
          x.translation,
          x.description
        ])
        ..join(object: (x) => x.user)
          .returningProperties((x) => [x.id, x.username]);
      final currentWord = await qGetWord.fetchOne();
      return Response.ok(currentWord);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения слова");
    }
  }

  // @Operation.get()
  // Future<Response> getAllTasks() async {
  //   try {
  //     final qGetAllTasks = Query<Task>(managedContext)
  //       ..returningProperties((x) => [
  //             x.id,
  //             x.title,
  //             x.content,
  //             x.createdAt,
  //             x.startOfWork,
  //             x.endOfWork,
  //             x.imageUrl,
  //             x.contractorCompany,
  //             x.responsibleMaster,
  //             x.representative,
  //             x.equipmentLevel,
  //             x.staffLevel,
  //             x.resultsOfTheWork,
  //             x.expenses,
  //             x.user,
  //             x.category,
  //             x.status,
  //             x.industry,
  //             x.taskType
  //           ])
  //       ..join(object: (x) => x.user)
  //           .returningProperties((x) => [x.id, x.username, x.email])
  //       ..join(object: (x) => x.status)
  //       ..join(object: (x) => x.industry)
  //       ..join(object: (x) => x.taskType)
  //       ..join(object: (x) => x.category);
  //     final List<Task> tasks = await qGetAllTasks.fetch();
  //     if (tasks.isEmpty) return Response.notFound();
  //     return Response.ok(tasks);
  //   } catch (error) {
  //     return AppResponse.serverError(error, message: "Ошибка вывода задач");
  //   }
  // }

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
  Future<Response> getWords() async {
    try {
      final qGetPosts = Query<Word>(managedContext);
      final List<Word> words = await qGetPosts.fetch();
      if (words.isEmpty) return Response.notFound();

      return Response.ok(words);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения слов");
    }
  }
}
