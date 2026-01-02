// //package
// import 'dart:convert';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// //models
// import '../models/movie.dart';

// //Lấy danh sách phim yêu thích và cung cấp các phương thức để quản lý
// final favouriteMoviesProvider =
//     NotifierProvider<FavouriteMoviesController, List<Movie>>(
//       () => FavouriteMoviesController(),
//     );

// //quản lý trạng thái danh sách phim yêu thích
// class FavouriteMoviesController extends Notifier<List<Movie>> {
//   static const String _prefsKey = 'favourites';

//   @override
//   List<Movie> build() {
//     //Khởi tạo danh sách yêu thích từ SharedPreferences
//     loadFavorites();
//     return [];
//   }

//   Future<void> loadFavorites() async {
//     //Lấy danh sách yêu thích từ SharedPreferences
//     final prefs = await SharedPreferences.getInstance(); //
//     final favouriteList =
//         prefs.getStringList(_prefsKey) ?? []; //Lấy danh sách chuỗi JSON
//     state = favouriteList
//         .map((e) => Movie.fromJson(jsonDecode(e)))
//         .toList(); //Chuyển chuỗi JSON thành đối tượng Movie
//   }
//   //map((e) => ...) // duyệt từng chuỗi json trong danh sách
//   //jsonDecode(e) //chuyển chuỗi json thành Map<String, dynamic>
//   //Movie.fromJson(...) //chuyển Map<String, dynamic> thành đối tượng Movie
//   //toList() //chuyển thành List<Movie>

//   Future<void> saveFavorites() async {
//     final prefs = await SharedPreferences.getInstance();
//     final favouriteList = state
//         .map((e) => jsonEncode(e.toJson()))
//         .toList(); //Chuyển đối tượng Movie thành chuỗi JSON
//     await prefs.setStringList(_prefsKey, favouriteList);
//   }
//   // Movie → Map (toJson) → String (jsonEncode) → List<String>

//   bool isFavorite(int movieId) {
//     //Kiểm tra phim có trong danh sách yêu thích không
//     return state.any((movie) => movie.id == movieId);
//   }

//   Future<void> toggleFavorite(Movie movie) async {
//     if (isFavorite(movie.id)) {
//       state = state.where((m) => m.id != movie.id).toList();
//     } else {
//       state = [...state, movie];
//     }
//     await saveFavorites();
//   }

//   Future<void> removeFavorite(int movieId) async {
//     state = state.where((movie) => movie.id != movieId).toList();
//     await saveFavorites();
//   }

//   Future<void> clearFavorites() async {
//     state = [];
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_prefsKey);
//   }
// }

import 'dart:convert';
import 'package:flickd_app/models/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../services/auth_service.dart'; // lấy userId hiện tại
import '../services/movie_service.dart'; // để fetch detail từng movie theo id

final favouriteMoviesProvider =
    NotifierProvider<FavouriteMoviesController, List<Movie>>(
      () => FavouriteMoviesController(),
    );

class FavouriteMoviesController extends Notifier<List<Movie>> {
  final String _baseUrl =
      '${GetIt.instance<AppConfig>().BE_URL}/wishlist'; // từ config

  int? _userId;

  int? get userId => _userId;

  /// Set currently logged in user id (call this after login)
  void setUserId(int? id) {
    _userId = id;
    if (id != null) fetchFavorites();
  }

  // Khởi tạo từ backend
  @override
  List<Movie> build() {
    // Try loading saved userId from prefs (non-blocking)
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
        state = movies.whereType<Movie>().toList();
      } else {
        state = [];
      }
    } catch (e) {
      state = [];
    }
  }

  Future<bool> addFavorite(Movie movie) async {
    // Optimistic local update so UI toggles immediately
    if (!isFavorite(movie.id)) {
      state = [...state, movie];
    }

    if (userId == null)
      return true; // can't sync to server yet, treat as success

    try {
      final uri = Uri.parse('$_baseUrl/add');
      final bodyMap = {
        'userId': userId.toString(),
        'filmId': movie.id.toString(),
      };
      final res = await http.post(uri, body: bodyMap);
      if (res.statusCode == 200) {
        // refresh from server to get canonical wishlist
        await fetchFavorites();
        return true;
      } else {
        // revert on failure
        state = state.where((m) => m.id != movie.id).toList();
        return false;
      }
    } catch (e) {
      // network error: revert optimistic change
      state = state.where((m) => m.id != movie.id).toList();
      return false;
    }
    return false;
  }

  /// Toggle favorite: add if not favorite, remove if already favorite
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
    // Optimistic local removal
    final existed = isFavorite(movieId);
    if (existed) state = state.where((m) => m.id != movieId).toList();

    if (userId == null) return false; // nothing to sync

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
      // network error: nothing further here
      return false;
    }
  }

  bool isFavorite(int movieId) {
    return state.any((movie) => movie.id == movieId);
  }
}
