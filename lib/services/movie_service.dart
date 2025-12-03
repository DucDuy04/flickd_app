//package
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

//service
import '../services/http_service.dart';

//models
import '../models/movie.dart';

class MovieService {
  final GetIt getIt = GetIt.instance;

  HTTPService? _http;

  MovieService() {
    _http = getIt<HTTPService>();
  }

  Future<List<Movie>> getPopularMovies({int? page}) async {
    Response? _response = await _http?.get(
      '/movie/popular',
      query: {'page': page},
    );

    if (_response?.statusCode == 200) {
      Map _data = _response!.data;
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
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getUpcomingMovies({int? page}) async {
    Response? _response = await _http?.get(
      '/movie/upcoming',
      query: {'page': page},
    );
    if (_response?.statusCode == 200) {
      Map _data = _response!.data;
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
      Map _data = _response!.data;
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
