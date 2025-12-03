//models
import '../models/app_config.dart';

//package
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class HTTPService {
  final Dio dio = Dio();
  final GetIt getIt = GetIt.instance;

  String? _base_url;
  String? _api_key;

  HTTPService() {
    AppConfig config = GetIt.instance<AppConfig>();
    _base_url = config.BASE_API_URL;
    _api_key = config.API_KEY;
  }

  Future<Response?> get(String _path, {Map<String, dynamic>? query}) async {
    try {
      String _url = '$_base_url$_path';
      Map<String, dynamic> _query = {'api_key': _api_key, 'language': 'en-US'};
      if (query != null) {
        _query.addAll(query);
      }
      return await dio.get(_url, queryParameters: _query);
    } on DioException catch (e) {
      print('Unable to perform get request');
      print('DioException: $e');
      // return null;
    }
  }
}
