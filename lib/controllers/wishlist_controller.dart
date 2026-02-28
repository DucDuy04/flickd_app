import 'dart:convert';
import 'package:flickd_app/models/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../services/movie_service.dart';

final favouriteMoviesProvider =
    NotifierProvider<FavouriteMoviesController, List<Movie>>(
      () => FavouriteMoviesController(),
    );

class FavouriteMoviesController extends Notifier<List<Movie>> {
  final String _baseUrl =
      '${GetIt.instance<AppConfig>().BE_URL}/wishlist'; // từ config

  int? _userId;

  int? get userId => _userId;

  //set userId khi đăng nhập
  void setUserId(int? id) {
    _userId = id;
    if (id != null) fetchFavorites();
  }

  // Khởi tạo từ backend
  @override
  List<Movie> build() {
    _loadSavedUserId();
    fetchFavorites();
    return [];
  }

  Future<void> _loadSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('userId');
      if (saved != null) {
        _userId = saved;
        fetchFavorites();
      }
    } catch (e) {
      // ignore errors silently
    }
  }

  /// Lấy list filmId, rồi fetch detail từng movie
  Future<void> fetchFavorites() async {
    if (userId == null) return;
    try {
      //Gọi BE để lấy filmIds favorite
      final uri = Uri.parse('$_baseUrl/user/$userId');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List<dynamic> filmIds = json.decode(res.body);
        // Lấy chi tiết cho từng filmId (gọi đồng thời). Chuyển id về int an toàn.
        final movieService = MovieService();
        final movies = await Future.wait(
          filmIds.map((id) {
            final parsedId = int.tryParse(id.toString());
            if (parsedId == null) return Future<Movie?>.value(null);
            return movieService.fetchMovieById(parsedId);
          }),
        );
        // Lọc null và gán lại state
        state = movies.whereType<Movie>().toList();
      } else {
        state = [];
      }
    } catch (e) {
      state = [];
    }
  }

  Future<bool> addFavorite(Movie movie) async {
    //state là list<Movie> đã có
    //movie là phim cần thêm
    //state mới = state cũ + movie
    if (!isFavorite(movie.id)) {
      state = [...state, movie];
    }

    if (userId == null) return true;

    try {
      final uri = Uri.parse('$_baseUrl/add');
      final bodyMap = {
        'userId': userId.toString(),
        'filmId': movie.id.toString(),
      };
      final res = await http.post(uri, body: bodyMap);
      if (res.statusCode == 200) {
        await fetchFavorites();
        return true;
      } else {
        state = state.where((m) => m.id != movie.id).toList();
        return false;
      }
    } catch (e) {
      state = state.where((m) => m.id != movie.id).toList();
      return false;
    }
    return false;
  }

  // Thêm hoặc xóa favorite tùy trạng thái hiện tại
  Future<bool> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      final ok = await removeFavorite(movie.id);
      return ok;
    } else {
      final ok = await addFavorite(movie);
      return ok;
    }
  }

  Future<bool> removeFavorite(int movieId) async {
    // Xóa khỏi state ngay
    final existed = isFavorite(movieId);
    if (existed) state = state.where((m) => m.id != movieId).toList();

    if (userId == null) return false;

    try {
      final uri = Uri.parse('$_baseUrl/remove');
      final bodyMap = {
        'userId': userId.toString(),
        'filmId': movieId.toString(),
      };
      final res = await http.post(uri, body: bodyMap);
      if (res.statusCode == 200) {
        await fetchFavorites();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool isFavorite(int movieId) {
    return state.any((movie) => movie.id == movieId);
  }
}
