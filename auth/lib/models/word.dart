import 'package:conduit_core/conduit_core.dart';
import 'package:auth/models/user.dart';


class Word extends ManagedObject<_Word> implements _Word{}

// 'CREATE TABLE "$tableWord" ("id" INTEGER,"edition" DATE, "title" TEXT NOT NULL, "translation" TEXT NOT NULL, "description" TEXT, PRIMARY KEY("id" AUTOINCREMENT))';

class _Word{
  @primaryKey
  int? id;
  DateTime? edition;
  String? title;
  String? translation;
  String? description;
  @Relate(#wordList, isRequired: true, onDelete: DeleteRule.cascade) // onDelete: DeleteRule.cascade
  User? user;
}