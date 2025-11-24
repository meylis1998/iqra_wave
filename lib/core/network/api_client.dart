import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/network/dio_client.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@lazySingleton
@RestApi()
abstract class ApiClient {
  @factoryMethod
  factory ApiClient(DioClient dioClient) =>
      _ApiClient(dioClient.dio, baseUrl: AppConfig.quranApiBaseUrl);

  // Add Quran.Foundation API endpoints here as needed
}
