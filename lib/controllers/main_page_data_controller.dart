import 'package:flickd_app/models/search_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

//models
import '../models/main_page_data.dart';
import '../models/movie.dart';

//services
import '../services/movie_service.dart';

class MainPageDataController extends Notifier<MainPageData> {
  final MovieService _movieService = GetIt.instance<MovieService>();

  @override
  MainPageData build() {
    // Gọi getMovies SAU khi build xong
    Future.microtask(() => getMovies());
    return MainPageData.initial();
  }

  Future<void> getMovies() async {
    try {
      List<Movie> _movies = [];

      if (state.searchText.isEmpty) {
        if (state.searchCategory == SearchCategory.popular) {
          _movies = await _movieService.getPopularMovies(page: state.page);
        } else if (state.searchCategory == SearchCategory.upcoming) {
          _movies = await _movieService.getUpcomingMovies(page: state.page);
        } else if (state.searchCategory == SearchCategory.none) {
          _movies = [];
        }
      } else {
        _movies = await _movieService.searchMovies(
          state.searchText,
          page: state.page,
        );
      }
      state = state.copyWith(
        movies: [...state.movies, ..._movies],
        page: state.page + 1,
      );
    } catch (e) {
      print(e);
    }
  }

  void updateSearchCategory(String _category) {
    try {
      state = state.copyWith(
        movies: [],
        page: 1,
        searchCategory: _category,
        searchText: '',
      );
      getMovies();
    } catch (e) {}
  }

  void updateSearchText(String _searchText) {
    try {
      state = state.copyWith(
        movies: [],
        page: 1,
        searchCategory: SearchCategory.none,
        searchText: _searchText,
      );
      getMovies();
    } catch (e) {
      print(e);
    }
  }
}
