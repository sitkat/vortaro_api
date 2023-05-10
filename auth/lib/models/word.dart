import 'package:conduit_core/conduit_core.dart';
import 'package:auth/models/user.dart';

import 'favorite.dart';


class Word extends ManagedObject<_Word> implements _Word{}

class _Word{
  @primaryKey
  int? id;
  DateTime? edition;
  String? title;
  String? translation;
  String? description;

  @Relate(#wordList, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;

  ManagedSet<Favorite>? favoriteWordList;
}