//package
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//models
import '../models/movie.dart';

//Lấy danh sách phim yêu thích và cung cấp các phương thức để quản lý
final favouriteMoviesProvider =
    NotifierProvider<FavouriteMoviesController, List<Movie>>(
      () => FavouriteMoviesController(),
    );

//quản lý trạng thái danh sách phim yêu thích
class FavouriteMoviesController extends Notifier<List<Movie>> {
  static const String _prefsKey = 'favourites';

  @override
  List<Movie> build() {
    //Khởi tạo danh sách yêu thích từ SharedPreferences
    loadFavorites();
    return [];
  }

  Future<void> loadFavorites() async {
    //Lấy danh sách yêu thích từ SharedPreferences
    final prefs = await SharedPreferences.getInstance(); //
    final favouriteList =
        prefs.getStringList(_prefsKey) ?? []; //Lấy danh sách chuỗi JSON
    state = favouriteList
        .map((e) => Movie.fromJson(jsonDecode(e)))
        .toList(); //Chuyển chuỗi JSON thành đối tượng Movie
  }
  //map((e) => ...) // duyệt từng chuỗi json trong danh sách
  //jsonDecode(e) //chuyển chuỗi json thành Map<String, dynamic>
  //Movie.fromJson(...) //chuyển Map<String, dynamic> thành đối tượng Movie
  //toList() //chuyển thành List<Movie>

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favouriteList = state
        .map((e) => jsonEncode(e.toJson()))
        .toList(); //Chuyển đối tượng Movie thành chuỗi JSON
    await prefs.setStringList(_prefsKey, favouriteList);
  }
  // Movie → Map (toJson) → String (jsonEncode) → List<String>

  bool isFavorite(int movieId) {
    //Kiểm tra phim có trong danh sách yêu thích không
    return state.any((movie) => movie.id == movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      state = state.where((m) => m.id != movie.id).toList();
    } else {
      state = [...state, movie];
    }
    await saveFavorites();
  }

  Future<void> removeFavorite(int movieId) async {
    state = state.where((movie) => movie.id != movieId).toList();
    await saveFavorites();
  }

  Future<void> clearFavorites() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
