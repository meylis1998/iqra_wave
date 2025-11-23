import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:iqra_wave/core/di/injection_container.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton(InternetConnection.new)
    ..registerLazySingleton(Dio.new)
    ..init();
}
