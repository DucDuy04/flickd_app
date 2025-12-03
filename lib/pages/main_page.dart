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
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final mainPageDataController = ref.watch(
      mainPageDataControllerProvider.notifier,
    );
    final mainPageData = ref.watch(mainPageDataControllerProvider);

    final selectMoviePosterURL = ref.watch(selectedMoviePosterProvider);
    final selectedMoviePosterNotifier = ref.watch(
      selectedMoviePosterProvider.notifier,
    );

    final searchTextFieldController = TextEditingController();
    searchTextFieldController.text = mainPageData.searchText;

    return _buildUI(
      deviceHeight,
      deviceWidth,
      mainPageDataController,
      mainPageData,
      selectMoviePosterURL,
      selectedMoviePosterNotifier,
      searchTextFieldController,
    );
  }

  Widget _buildUI(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    String? selectMoviePosterURL,
    SelectedMoviePosterNotifier notifier,
    TextEditingController searchTextFieldController,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Container(
        height: deviceHeight,
        width: deviceWidth,
        child: Stack(
          children: [
            _backgroundWidget(deviceHeight, deviceWidth, selectMoviePosterURL),
            _foregroundWidgets(
              deviceHeight,
              deviceWidth,
              mainPageDataController,
              mainPageData,
              notifier,
              searchTextFieldController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundWidget(
    double deviceHeight,
    double deviceWidth,
    String? selectMoviePosterURL,
  ) {
    if (selectMoviePosterURL != null) {
      return Container(
        width: deviceWidth,
        height: deviceHeight,
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
        width: deviceWidth,
        height: deviceHeight,
        color: Colors.black,
      );
    }
  }

  Widget _foregroundWidgets(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    SelectedMoviePosterNotifier notifier,
    TextEditingController searchTextFieldController,
  ) {
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, deviceHeight * 0.02, 0, 0),
        width: deviceWidth * 0.88,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _topBarWidget(
              deviceHeight,
              deviceWidth,
              mainPageDataController,
              mainPageData,
              searchTextFieldController,
            ),
            SizedBox(height: deviceHeight * 0.02),
            Container(
              height: deviceHeight * 0.83,
              padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.01),
              child: _movieListViewWidget(
                deviceHeight,
                deviceWidth,
                mainPageDataController,
                mainPageData,
                notifier,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBarWidget(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    TextEditingController searchTextFieldController,
  ) {
    return Container(
      height: deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _searchFieldWidget(
            deviceHeight,
            deviceWidth,
            mainPageDataController,
            searchTextFieldController,
          ),
          _categorySelectionWidget(mainPageDataController, mainPageData),
        ],
      ),
    );
  }

  Widget _searchFieldWidget(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    TextEditingController searchTextFieldController,
  ) {
    final border = InputBorder.none;
    return Container(
      width: deviceWidth * 0.50,
      height: deviceHeight * 0.05,
      child: TextField(
        controller: searchTextFieldController,
        onSubmitted: (input) => mainPageDataController.updateSearchText(input),
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          focusedBorder: border,
          border: border,
          prefixIcon: Icon(Icons.search, color: Colors.white24),
          hintStyle: TextStyle(color: Colors.white54),
          filled: false,
          fillColor: Colors.white24,
          hintText: 'Search....',
        ),
      ),
    );
  }

  Widget _categorySelectionWidget(
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
  ) {
    return DropdownButton(
      dropdownColor: Colors.black38,
      value: mainPageData.searchCategory,
      icon: Icon(Icons.menu, color: Colors.white24),
      underline: Container(height: 1, color: Colors.white24),
      onChanged: (value) {
        if (value != null && value.toString().isNotEmpty) {
          mainPageDataController.updateSearchCategory(value);
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
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    SelectedMoviePosterNotifier notifier,
  ) {
    final movies = mainPageData.movies;

    if (movies.isNotEmpty) {
      return NotificationListener(
        onNotification: (onScrollNotification) {
          if (onScrollNotification is ScrollEndNotification) {
            final before = onScrollNotification.metrics.extentBefore;
            final max = onScrollNotification.metrics.maxScrollExtent;
            if (before == max) {
              mainPageDataController.getMovies();
              return true;
            }
            return false;
          }
          return false;
        },
        child: ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, count) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: deviceHeight * 0.01,
                horizontal: 0,
              ),
              child: GestureDetector(
                onTap: () {
                  notifier.setUrl(movies[count].posterUrl());
                },
                child: MovieTile(
                  movie: movies[count],
                  height: deviceHeight * 0.20,
                  width: deviceWidth * 0.85,
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
