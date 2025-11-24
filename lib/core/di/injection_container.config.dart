// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_access_token.dart' as _i1020;
import '../../features/auth/domain/usecases/get_user_info.dart' as _i688;
import '../../features/auth/domain/usecases/logout_user.dart' as _i419;
import '../../features/auth/domain/usecases/refresh_token.dart' as _i209;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../network/api_client.dart' as _i557;
import '../network/dio_client.dart' as _i667;
import '../network/network_info.dart' as _i932;
import '../security/device_security_service.dart' as _i1068;
import '../services/biometric_service.dart' as _i374;
import '../services/observability_service.dart' as _i1050;
import '../services/performance_monitor.dart' as _i759;
import '../services/preferences_service.dart' as _i627;
import '../services/token_refresh_manager.dart' as _i251;
import '../services/token_refresh_scheduler.dart' as _i405;
import '../services/token_service.dart' as _i227;
import '../theme/theme_cubit.dart' as _i611;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i611.ThemeCubit>(() => _i611.ThemeCubit());
    gh.lazySingleton<_i1068.DeviceSecurityService>(
        () => _i1068.DeviceSecurityService());
    gh.lazySingleton<_i667.DioClient>(() => _i667.DioClient());
    gh.lazySingleton<_i374.BiometricService>(() => _i374.BiometricService());
    gh.lazySingleton<_i759.PerformanceMonitor>(
        () => _i759.PerformanceMonitor());
    gh.lazySingleton<_i1050.ObservabilityService>(
        () => _i1050.ObservabilityService());
    gh.lazySingleton<_i627.PreferencesService>(
        () => _i627.PreferencesService(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i227.TokenService>(
        () => _i227.TokenService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          gh<_i107.AuthRemoteDataSource>(),
          gh<_i227.TokenService>(),
        ));
    gh.lazySingleton<_i932.NetworkInfo>(
        () => _i932.NetworkInfoImpl(gh<_i161.InternetConnection>()));
    gh.lazySingleton<_i1020.GetAccessToken>(
        () => _i1020.GetAccessToken(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i419.LogoutUser>(
        () => _i419.LogoutUser(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i688.GetUserInfo>(
        () => _i688.GetUserInfo(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i209.RefreshToken>(
        () => _i209.RefreshToken(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i557.ApiClient>(
        () => _i557.ApiClient(gh<_i667.DioClient>()));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i1020.GetAccessToken>(),
          gh<_i209.RefreshToken>(),
          gh<_i688.GetUserInfo>(),
          gh<_i419.LogoutUser>(),
          gh<_i787.AuthRepository>(),
        ));
    gh.lazySingleton<_i251.TokenRefreshManager>(
        () => _i251.TokenRefreshManager(gh<_i1020.GetAccessToken>()));
    gh.lazySingleton<_i405.TokenRefreshScheduler>(
      () => _i405.TokenRefreshScheduler(
        gh<_i227.TokenService>(),
        gh<_i251.TokenRefreshManager>(),
      ),
      dispose: (i) => i.dispose(),
    );
    return this;
  }
}
