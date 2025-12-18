//models
import './movie.dart';
import './search_category.dart';

class MainPageData {
  final List<Movie> movies;
  final int page;
  final String searchCategory;
  final String searchText;

  MainPageData({
    required this.movies,
    required this.page,
    required this.searchCategory,
    required this.searchText,
  });

  MainPageData.initial() //Giá trị khởi tạo mặc định
    : movies = [],
      page = 1,
      searchCategory = SearchCategory.popular,
      searchText = '';

  MainPageData copyWith({
    //Tạo 1 bản sao với các giá trị có thể thay đổi
    //Chỉ thay giá trị được truyền vào, còn lại giữ nguyên
    List<Movie>? movies,
    int? page,
    String? searchCategory,
    String? searchText,
  }) {
    return MainPageData(
      movies: movies ?? this.movies, //this.movies là movies cũ
      page: page ?? this.page,
      searchCategory: searchCategory ?? this.searchCategory,
      searchText: searchText ?? this.searchText,
    );
  }
}
