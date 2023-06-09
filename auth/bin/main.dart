import 'package:auth/auth.dart';
import 'package:auth/utils/app_env.dart';
import 'package:conduit_core/conduit_core.dart';

import 'package:auth/models/word.dart';
import 'package:auth/models/user.dart';
import 'package:auth/models/favorite.dart';

void main(List<String> arguments) async {
  final int port = int.tryParse(AppEnv.port) ?? 0;
  final service = Application<AppService>()..options.port = port;
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
