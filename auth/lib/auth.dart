import 'package:auth/controllers/app_auth_controller.dart';
import 'package:auth/controllers/app_favorite_controller.dart';
import 'package:auth/controllers/app_token_controller.dart';
import 'package:auth/controllers/app_user_controller.dart';
import 'package:auth/controllers/app_word_controller.dart';
import 'package:auth/utils/app_env.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';

import 'package:auth/models/word.dart';
import 'package:auth/models/user.dart';
import 'package:auth/models/favorite.dart';


class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route("token/[:refresh]").link(() => AppAuthController(managedContext))
    ..route("user")
        .link(() => AppTokenController())!
        .link(() => AppUserController(managedContext))
    ..route("word/[:id]")
        .link(() => AppTokenController())!
        .link(() => AppWordController(managedContext))
    ..route("favorite/[:id]")
        .link(() => AppTokenController())!
        .link(() => AppFavoriteController(managedContext));

  PostgreSQLPersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(AppEnv.dbUsername, AppEnv.dbPassword,
        AppEnv.dbHost, int.tryParse(AppEnv.dbPort), AppEnv.dbDatabaseName);
  }
}
