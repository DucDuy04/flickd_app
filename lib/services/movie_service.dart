//package
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

//service
import '../services/http_service.dart';

//models
import '../models/movie.dart';

class MovieService {
  //Lấy instance GetIt toàn cục
  final GetIt getIt = GetIt.instance;

  //Khai báo biến _http kiểu HTTPService? (có thể null)
  HTTPService? _http;

  //Khởi tạo MovieService, gán biến _http với instance HTTPService từ GetIt
  //Nếu chưa đăng ký HTTPService trong GetIt, sẽ báo lỗi khi chạy
  MovieService() {
    _http = getIt<HTTPService>();
  }

  Future<List<Movie>> getPopularMovies({int? page}) async {
    //Gọi method get của HTTPService với truyền path /movie/popular và query page
    Response? _response = await _http?.get(
      '/movie/popular',
      query: {'page': page},
    );

    if (_response?.statusCode == 200) {
      //Nếu status code là 200 (thành công), parse dữ liệu
      Map<String, dynamic> _data = _response!.data;
      List<Movie> _movies = [];

      for (var movieData in _data['results']) {
        try {
          //Chuyển phần tử trong mảng result(Json) thành Movie và thêm vào list
          _movies.add(Movie.fromJson(movieData));
        } catch (e) {
          print('Error parsing movie: $e');
        }
      }

      return _movies;
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getUpcomingMovies({int? page}) async {
    Response? _response = await _http?.get(
      '/movie/upcoming',
      query: {'page': page},
    );
    if (_response?.statusCode == 200) {
      Map<String, dynamic> _data = _response!.data;
      List<Movie> _movies = [];

      for (var movieData in _data['results']) {
        try {
          _movies.add(Movie.fromJson(movieData));
        } catch (e) {
          print('Error parsing movie: $e');
        }
      }

      return _movies;
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<Movie>> searchMovies(String _searchTerm, {int? page}) async {
    Response? _response = await _http?.get(
      '/search/movie',
      query: {'query': _searchTerm, 'page': page},
    );

    if (_response?.statusCode == 200) {
      Map<String, dynamic> _data = _response!.data;
      List<Movie> _movies = [];

      for (var movieData in _data['results']) {
        try {
          _movies.add(Movie.fromJson(movieData));
        } catch (e) {
          print('Error parsing movie: $e');
          // Bỏ qua phim lỗi, tiếp tục parse phim khác
        }
      }

      return _movies;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
