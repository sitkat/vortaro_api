import 'package:conduit_core/conduit_core.dart';

class Favorite extends ManagedObject<_Favorite> implements _Favorite{}

class _Favorite{
  @primaryKey
  int? id;
  String? content;
}