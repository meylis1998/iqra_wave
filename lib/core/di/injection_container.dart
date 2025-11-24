import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:iqra_wave/core/di/injection_container.config.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async => getIt.init();

@module
abstract class ExternalDependenciesModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  InternetConnection get internetConnection => InternetConnection();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
