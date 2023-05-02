import 'package:conduit_core/conduit_core.dart';

import 'user.dart';
import 'word.dart';

class Favorite extends ManagedObject<_Favorite> implements _Favorite{}

class _Favorite{
  @primaryKey
  int? id;
  
  @Relate(#favoriteUserList, isRequired: true, onDelete: DeleteRule.cascade) // onDelete: DeleteRule.cascade
  User? user;
  @Relate(#favoriteWordList, isRequired: true, onDelete: DeleteRule.cascade) // onDelete: DeleteRule.cascade
  Word? word;
}