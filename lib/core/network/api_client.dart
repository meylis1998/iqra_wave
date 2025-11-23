import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/models/user_model.dart';
import 'package:iqra_wave/core/network/dio_client.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@lazySingleton
@RestApi()
abstract class ApiClient {
  @factoryMethod
  factory ApiClient(DioClient dioClient) => _ApiClient(dioClient.dio);

  @GET(ApiConstants.users)
  Future<List<UserModel>> getUsers();

  @GET('${ApiConstants.users}/{id}')
  Future<UserModel> getUser(@Path('id') int id);

  // Note: Login/register are not needed for OAuth2 client_credentials flow
  // These endpoints are for legacy/testing purposes only
  // If needed, create proper response models instead of Map<String, dynamic>

  // @POST(ApiConstants.login)
  // Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> credentials);

  // @POST(ApiConstants.register)
  // Future<Map<String, dynamic>> register(@Body() Map<String, dynamic> userData);
}
