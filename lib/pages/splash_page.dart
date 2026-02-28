import 'dart:convert';
//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

//services
import '../services/http_service.dart';
import '../services/movie_service.dart';

//models
import '../models/app_config.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;
  //Hàm callback được gọi khi app khởi tạo xong

  //Khởi tạo SplashPage với tham số bắt buộc onInitializationComplete
  const SplashPage({Key? key, required this.onInitializationComplete})
    : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    //Đợi 2 giây rồi gọi hàm _setup để khởi tạo app
    Future.delayed(Duration(seconds: 2)).then(
      (_) => _setup(context).then((_) => widget.onInitializationComplete()),
    );
  }

  Future<void> _setup(BuildContext _context) async {
    //HÀm bất đồng bộ, đọc config và đăng ký các service trong GetIt
    final getIt = GetIt.instance;

    //Đọc file config JSON từ assets
    final configFile = await rootBundle.loadString('assets/config/main.json');
    //rootBundle.loadString lấy nội dung file asset ở đường dẫn đó. File phải được khai báo trong pubspec.yaml.
    final configData = jsonDecode(configFile);
    //jsonDecode chuyển chuỗi JSON thành Map (configData).

    //Đăng ký AppConfig, HTTPService, MovieService trong GetIt
    //AppConfig chứa các cấu hình từ file JSON
    getIt.registerSingleton<AppConfig>(
      AppConfig(
        API_KEY: configData['API_KEY'],
        BASE_API_URL: configData['BASE_API_URL'],
        BASE_IMAGE_API_URL: configData['BASE_IMAGE_API_URL'],
        BE_URL: configData['BE_URL'],
      ),
    );
    //Lưu ý: cái nào đăng ký trước thì sẽ được lấy ra trước nếu có phụ thuộc lẫn nhau
    //Ở đây HTTPService phụ thuộc AppConfig nên phải đăng ký AppConfig trước
    getIt.registerSingleton<HTTPService>(HTTPService());

    //MovieService dùng để:Gọi API phim,Parse dữ liệu,Trả về danh sách Movie
    getIt.registerSingleton<MovieService>(MovieService());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flickd',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Center(
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage('assets/images/logo.png'),
            ),
          ),
        ),
      ),
    );
  }
}

//SplashPage là màn hình khởi động ứng dụng, có nhiệm vụ hiển thị logo trong 2 giây, 
//đồng thời đọc file cấu hình từ assets và đăng ký các service Singleton
// bằng GetIt như AppConfig, HTTPService và MovieService. Sau khi khởi tạo xong,
//SplashPage gọi callback để chuyển sang màn hình chính của ứng dụng.