//Packages
import 'dart:ui';

//package
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//widget
import '../widgets/movie_tile.dart';

//models
import '../models/search_category.dart';
import '../models/movie.dart';
import '../models/main_page_data.dart';

//controllers
import '../controllers/main_page_data_controller.dart';

final mainPageDataControllerProvider =
    NotifierProvider<MainPageDataController, MainPageData>(() {
      return MainPageDataController();
    });

class SelectedMoviePosterNotifier extends Notifier<String?> {
  @override
  String? build() {
    final movies = ref.watch(mainPageDataControllerProvider).movies;
    return movies.isNotEmpty ? movies[0].posterUrl() : null;
  }

  void setUrl(String url) {
    state = url;
  }
}

final selectedMoviePosterProvider =
    NotifierProvider<SelectedMoviePosterNotifier, String?>(() {
      return SelectedMoviePosterNotifier();
    });

class MainPage extends ConsumerWidget {
  double? _deviceHeight;
  double? _deviceWidth;

  MainPageDataController? _mainPageDataController;
  MainPageData? _mainPageData;

  TextEditingController? _searchTextFieldController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _mainPageDataController = ref.watch(
      mainPageDataControllerProvider.notifier,
    );
    _mainPageData = ref.watch(mainPageDataControllerProvider);

    final _selectMoviePosterURL = ref.watch(selectedMoviePosterProvider);
    final _selectedMoviePosterNotifier = ref.watch(
      selectedMoviePosterProvider.notifier,
    );

    _searchTextFieldController = TextEditingController();

    _searchTextFieldController?.text = _mainPageData!.searchText;
    return _buildUI(
      _mainPageData,
      _selectMoviePosterURL,
      _selectedMoviePosterNotifier,
    );
  }

  Widget _buildUI(
    MainPageData? mainPageData,
    String? _selectMoviePosterURL,
    SelectedMoviePosterNotifier _notifier,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Container(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(
          children: [
            _backgroundWidget(_selectMoviePosterURL),
            _foregroundWidgets(mainPageData, _notifier),
          ],
        ),
      ),
    );
  }

  Widget _backgroundWidget(String? selectMoviePosterURL) {
    if (selectMoviePosterURL != null) {
      return Container(
        width: _deviceWidth,
        height: _deviceHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            image: NetworkImage(selectMoviePosterURL),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
          ),
        ),
      );
    } else {
      return Container(
        width: _deviceWidth,
        height: _deviceHeight,
        color: Colors.black,
      );
    }
  }

  Widget _foregroundWidgets(
    MainPageData? mainPageData,
    SelectedMoviePosterNotifier notifier,
  ) {
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, _deviceHeight! * 0.02, 0, 0),
        width: _deviceWidth! * 0.88,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _topBarWidget(),
            SizedBox(height: _deviceHeight! * 0.02),
            Container(
              height: _deviceHeight! * 0.83,
              padding: EdgeInsets.symmetric(vertical: _deviceHeight! * 0.01),
              child: _movieListViewWidget(mainPageData, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBarWidget() {
    return Container(
      height: _deviceHeight! * 0.08,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_searchFieldWidget(), _categorySelectionWidget()],
      ),
    );
  }

  Widget _searchFieldWidget() {
    final _border = InputBorder.none;
    return Container(
      width: _deviceWidth! * 0.50,
      height: _deviceHeight! * 0.05,
      child: TextField(
        controller: _searchTextFieldController,
        onSubmitted: (_input) =>
            _mainPageDataController!.updateSearchText(_input),
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          focusedBorder: _border,
          border: _border,
          prefixIcon: Icon(Icons.search, color: Colors.white24),
          hintStyle: TextStyle(color: Colors.white54),
          filled: false,
          fillColor: Colors.white24,
          hintText: 'Search....',
        ),
      ),
    );
  }

  Widget _categorySelectionWidget() {
    return DropdownButton(
      dropdownColor: Colors.black38,
      value: _mainPageData?.searchCategory,
      icon: Icon(Icons.menu, color: Colors.white24),
      underline: Container(height: 1, color: Colors.white24),
      onChanged: (_value) {
        if (_value != null && _value.toString().isNotEmpty) {
          _mainPageDataController!.updateSearchCategory(_value);
        }
      },
      items: [
        DropdownMenuItem(
          child: Text(
            SearchCategory.popular,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.popular,
        ),
        DropdownMenuItem(
          child: Text(
            SearchCategory.upcoming,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.upcoming,
        ),
        DropdownMenuItem(
          child: Text(
            SearchCategory.none,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.none,
        ),
      ],
    );
  }

  Widget _movieListViewWidget(
    MainPageData? mainPageData,
    SelectedMoviePosterNotifier notifier,
  ) {
    final List<Movie> _movies = mainPageData?.movies ?? [];

    if (_movies.length != 0) {
      return NotificationListener(
        onNotification: (_onScrollNotification) {
          if (_onScrollNotification is ScrollEndNotification) {
            final before = _onScrollNotification.metrics.extentBefore;
            final max = _onScrollNotification.metrics.maxScrollExtent;
            if (before == max) {
              _mainPageDataController!.getMovies();
              return true;
            }
            return false;
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _movies.length,
          itemBuilder: (BuildContext _context, int _count) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: _deviceHeight! * 0.01,
                horizontal: 0,
              ),
              child: GestureDetector(
                onTap: () {
                  notifier.setUrl(_movies[_count].posterUrl());
                },
                child: MovieTile(
                  movie: _movies[_count],
                  height: _deviceHeight! * 0.20,
                  width: _deviceWidth! * 0.85,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(backgroundColor: Colors.white),
      );
    }
  }
}
