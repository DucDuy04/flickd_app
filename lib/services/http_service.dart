//models
import '../models/app_config.dart';

//package
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

//Gửi request HTTP (ở đây là GET) tới endpoint (_base_url + _path)
// với query params mặc định (api_key, language) và query phụ
class HTTPService {
  final Dio dio = Dio();
  final GetIt getIt = GetIt.instance;

  String? _base_url;
  String? _api_key;

  HTTPService() {
    AppConfig config = GetIt.instance<AppConfig>();
    //Lấy instance AppConfig từ GetIt
    //Gán 2 giá trị cần dùng cho biến
    _base_url = config.BASE_API_URL;
    _api_key = config.API_KEY;
  }

  //Khai báo phương thức get -> trả về Response hoặc null
  //Tham số bắt buộc: _path (endpoint cần gọi) : ví dụ: /movie/popular
  //Tham số tùy chọn: query (Map các query params bổ sung)
  Future<Response?> get(String _path, {Map<String, dynamic>? query}) async {
    try {
      String _url = '$_base_url$_path';
      Map<String, dynamic> _query = {'api_key': _api_key, 'language': 'en-US'};
      //tạo map query mặc định chứa api_key và language
      if (query != null) {
        _query.addAll(query);
        //Nếu truyền thêm query phụ, thêm vào map query mặc định
      }
      return await dio.get(_url, queryParameters: _query);
      //GỌi phương thức get của dio với url và query đã tạo
      //await đợi kq và trả về Response
    } on DioException catch (e) {
      print('Unable to perform get request');
      print('DioException: $e');
    }
    return null;
  }
}
