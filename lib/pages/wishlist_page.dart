import 'package:flickd_app/filter/wishlist_providers.dart';
import 'package:flickd_app/widgets/movie_wishlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final favorites = ref.watch(filteredAndSortedFavouritesProvider);

    return _BuildUI(deviceWidth, deviceHeight, favorites, ref);
  }

  Widget _BuildUI(
    double deviceWidth,
    double deviceHeight,
    List<Movie> favorites,
    WidgetRef ref,
  ) {
    return Container(
      width: deviceWidth,
      child: Stack(
        children: [
          _backgroundWidget(deviceWidth, deviceHeight),
          _allUIWidgets(deviceWidth, deviceHeight, favorites, ref),
        ],
      ),
    );
  }

  Widget _backgroundWidget(double deviceWidth, double deviceHeight) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, // to-br
            colors: [
              Color(0xFF78350F), // amber-900
              Color(0xFF1E293B), // slate-800
              Color(0xFF1E3A8A), // blue-900
            ],
          ),
        ),
      ),
    );
  }

  Widget _allUIWidgets(
    double deviceWidth,
    double deviceHeight,
    List<Movie> favorites,
    WidgetRef ref,
  ) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _topBarWidget(deviceWidth, deviceHeight, ref),
            SizedBox(
              height: deviceHeight * 0.02,
            ), //khoảng cách giữa top bar và danh sách phim
            Expanded(
              //Dùng Expanded để cho widget con chiếm toàn bộ không gian còn lại
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: deviceHeight * 0.01,
                ), //khoảng cách trên dưới
                child: _movieListViewWidget(
                  //danh sách phim
                  deviceHeight,
                  deviceWidth,
                  favorites,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBarWidget(double deviceWidth, double deviceHeight, WidgetRef ref) {
    return Material(
      color: const Color(0xCC0F172A),
      child: Padding(
        padding: EdgeInsets.only(
          top: deviceHeight * 0.02,
          left: 12,
          right: 12,
          bottom: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleBarWidget(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _filterSort(ref)),
                const SizedBox(width: 12),
                Expanded(child: _filterLanguage(ref)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleBarWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 25),
          child: Text(
            'My Wishlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, top: 16),
          child: Icon(Icons.favorite, color: Colors.redAccent, size: 32),
        ),
      ],
    );
  }

  Widget _filterSort(WidgetRef ref) {
    final currentSort = ref.watch(filtersProviders).sortBy;
    return DropdownButtonFormField<SortBy>(
      value: currentSort,
      dropdownColor: const Color(0xCC0F172A),
      items: const [
        DropdownMenuItem(
          value: SortBy.releaseDate,
          child: Text('Release Date', style: TextStyle(color: Colors.white)),
        ),
        DropdownMenuItem(
          value: SortBy.rating,
          child: Text('Rating', style: TextStyle(color: Colors.white)),
        ),
      ],
      onChanged: (v) {
        if (v != null) ref.read(filtersProviders.notifier).setSortBy(v);
      },
    );
  }

  Widget _filterLanguage(WidgetRef ref) {
    final currentLanguage = ref.watch(filtersProviders).languageCode;
    final languages = ref.watch(providedLanguagesProvider);

    return DropdownButtonFormField<String>(
      value: currentLanguage.toUpperCase(),
      dropdownColor: const Color(0xCC0F172A),
      items: languages.map((m) {
        final code = (m['code'] ?? 'ALL').toString().toUpperCase();
        return DropdownMenuItem(
          value: code,
          child: Text(
            m['label'] ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v == null) return;
        ref.read(filtersProviders.notifier).setLanguageCode(v.toUpperCase());
      },
    );
  }

  Widget _movieListViewWidget(
    double deviceHeight,
    double deviceWidth,
    List<Movie> favorites,
  ) {
    if (favorites.isEmpty) {
      return Center(
        child: Text(
          'Bạn chưa có phim yêu thích nào\ntrong danh sách.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }
    return ListView.builder(
      //danh sách phim dạng cuộn
      itemCount: favorites.length, //số lượng phần tử
      itemBuilder: (context, count) {
        //hàm xây dựng từng phần tử
        return Padding(
          padding: EdgeInsets.symmetric(
            //khoảng cách giữa các phần tử
            vertical: deviceHeight * 0.01, //khoảng cách trên dưới
            horizontal: 0, //khoảng cách trái phải
          ),
          child: MovieWishlist(
            //hiển thị thông tin phim
            movie: favorites[count], //truyền movie hiện tại
            height: deviceHeight * 0.20, //chiều cao tile
            width: deviceWidth * 0.85, //chiều rộng tile
          ),
        );
      },
    );
  }
}
