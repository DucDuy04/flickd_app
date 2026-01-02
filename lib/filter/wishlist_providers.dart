// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../controllers/wishlist_controller.dart';
// import '../models/movie.dart';

// enum SortBy { releaseDate, rating }

// //filter state
// class WishlistFilter {
//   final SortBy sortBy;
//   final String languageCode;

//   const WishlistFilter({
//     this.sortBy = SortBy.releaseDate,
//     this.languageCode = 'ALL',
//   });

//   WishlistFilter copyWith({SortBy? sortBy, String? languageCode}) {
//     return WishlistFilter(
//       sortBy: sortBy ?? this.sortBy,
//       languageCode: languageCode ?? this.languageCode,
//     );
//   }
// }

// //Lấy trang thái bộ lọc hiện tại và cung cấp các phương thức để cập nhật
// //bao gồm sắp xếp và lọc ngôn ngữ
// final filtersProviders =
//     NotifierProvider<WishlistFilterNotifier, WishlistFilter>(
//       () => WishlistFilterNotifier(),
//     );

// //quản lý trạng thái bộ lọc
// class WishlistFilterNotifier extends Notifier<WishlistFilter> {
//   @override
//   WishlistFilter build() {
//     return const WishlistFilter();
//   }

//   void setSortBy(SortBy newSortBy) {
//     state = state.copyWith(sortBy: newSortBy);
//   }

//   void setLanguageCode(String newLanguageCode) {
//     state = state.copyWith(languageCode: newLanguageCode);
//   }

//   void resetFilters() {
//     state = const WishlistFilter();
//   }
// }

// final providedLanguagesProvider = Provider<List<Map<String, String>>>((_) {
//   return [
//     {'code': 'ALL', 'label': 'All Languages'},
//     {'code': 'EN', 'label': 'English'},
//     {'code': 'NO', 'label': 'Norwegian'},
//     {'code': 'KN', 'label': 'Kannada'},
//   ];
// });

// final filteredAndSortedFavouritesProvider = Provider<List<Movie>>((ref) {
//   final favs = ref.watch(favouriteMoviesProvider); //danh sách yêu thích
//   final filters = ref.watch(filtersProviders); //bộ lọc hiện tại

//   final selectedLang = (filters.languageCode).toUpperCase(); //ngôn ngữ đã chọn

//   Iterable<Movie> res = favs; //danh sách phim yêu thích ban đầu
//   if (selectedLang != 'ALL') {
//     res = res.where((m) {
//       final raw = m.language.trim();
//       return raw.toUpperCase() == selectedLang;
//     });
//   }

//   final list = res.toList(); //chuyển Iterable<Movie> thành List<Movie>

//   DateTime _parseDate(String? s) {
//     //chuyển chuỗi ngày tháng thành DateTime
//     if (s == null)
//       return DateTime.fromMillisecondsSinceEpoch(0); //nếu null trả về ngày 0
//     return DateTime.tryParse(s) ??
//         DateTime.fromMillisecondsSinceEpoch(
//           0,
//         ); //nếu không parse được trả về ngày 0
//   }

//   if (filters.sortBy == SortBy.rating) {
//     list.sort((a, b) => b.rating.compareTo(a.rating)); // highest first
//   } else if (filters.sortBy == SortBy.releaseDate) {
//     list.sort(
//       (a, b) => _parseDate(b.releaseDate).compareTo(_parseDate(a.releaseDate)),
//     ); // newest first
//   }

//   return list; //trả về danh sách đã lọc và sắp xếp
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/wishlist_controller.dart'; // đã sửa, lấy từ backend qua API
import '../models/movie.dart';

enum SortBy { releaseDate, rating }

// Trạng thái filter
class WishlistFilter {
  final SortBy sortBy;
  final String languageCode;

  const WishlistFilter({
    this.sortBy = SortBy.releaseDate,
    this.languageCode = 'ALL',
  });

  WishlistFilter copyWith({SortBy? sortBy, String? languageCode}) {
    return WishlistFilter(
      sortBy: sortBy ?? this.sortBy,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

// Provider quản lý bộ lọc
final filtersProviders =
    NotifierProvider<WishlistFilterNotifier, WishlistFilter>(
      () => WishlistFilterNotifier(),
    );

// Notifier quản lý bộ lọc
class WishlistFilterNotifier extends Notifier<WishlistFilter> {
  @override
  WishlistFilter build() => const WishlistFilter();

  void setSortBy(SortBy newSortBy) {
    state = state.copyWith(sortBy: newSortBy);
  }

  void setLanguageCode(String newLanguageCode) {
    state = state.copyWith(languageCode: newLanguageCode);
  }

  void resetFilters() {
    state = const WishlistFilter();
  }
}

// Provider cho các ngôn ngữ hiển thị
final providedLanguagesProvider = Provider<List<Map<String, String>>>((_) {
  return [
    {'code': 'ALL', 'label': 'All Languages'},
    {'code': 'EN', 'label': 'English'},
    {'code': 'NO', 'label': 'Norwegian'},
    {'code': 'KN', 'label': 'Kannada'},
  ];
});

// Provider trả về danh sách phim đã lọc/sắp xếp
final filteredAndSortedFavouritesProvider = Provider<List<Movie>>((ref) {
  final favs = ref.watch(favouriteMoviesProvider); // --> lấy từ backend
  final filters = ref.watch(filtersProviders);

  final selectedLang = (filters.languageCode).toUpperCase();

  Iterable<Movie> res = favs;
  if (selectedLang != 'ALL') {
    res = res.where((m) {
      final raw = m.language.trim();
      return raw.toUpperCase() == selectedLang;
    });
  }

  final list = res.toList();

  DateTime _parseDate(String? s) {
    if (s == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  if (filters.sortBy == SortBy.rating) {
    list.sort((a, b) => b.rating.compareTo(a.rating));
  } else if (filters.sortBy == SortBy.releaseDate) {
    list.sort(
      (a, b) => _parseDate(b.releaseDate).compareTo(_parseDate(a.releaseDate)),
    );
  }

  return list;
});
