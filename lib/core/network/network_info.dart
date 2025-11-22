import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {

  NetworkInfoImpl(this.internetConnection);
  final InternetConnection internetConnection;

  @override
  Future<bool> get isConnected => internetConnection.hasInternetAccess;

  @override
  Stream<InternetStatus> get onStatusChange =>
      internetConnection.onStatusChange;
}
