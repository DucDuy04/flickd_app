//Packages
import 'dart:ui';

//package
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//widget
import '../widgets/movie_tile.dart';

//models
import '../models/search_category.dart';
import '../models/main_page_data.dart';

//controllers
import '../controllers/main_page_data_controller.dart';

//Providers chính quản lí toàn bộ trạng thái của MainPageData
//MainPageDataController xử lí logic
//MainPageData: dữ liệu(movies, page, searchCategory, searchText)
final mainPageDataControllerProvider =
    NotifierProvider<MainPageDataController, MainPageData>(() {
      return MainPageDataController();
    });

//Notifier quản lí trạng thái của poster movie được chọn
//Notifier chỉ quản lí duy nhất URL của poster được chọn làm bg
class SelectedMoviePosterNotifier extends Notifier<String?> {
  @override
  String? build() {
    //Lấy danh sách movies từ mainPageDataControllerProvider
    //Nếu có movies, trả về URL poster của movie đầu tiên, ngược lại trả về null
    final movies = ref.watch(mainPageDataControllerProvider).movies;
    return movies.isNotEmpty ? movies[0].posterUrl() : null;
  }

  // Phương thức cập nhật URL poster được chọn
  void setUrl(String url) {
    //Cập nhật trạng thái với URL mới
    //Khi click vào movie, URL của poster movie đó sẽ được truyền vào và cập nhật
    state = url;
  }
}

//Provider quản lí SelectedMoviePosterNotifier
//Trả về URL poster được chọn (String?)
final selectedMoviePosterProvider =
    NotifierProvider<SelectedMoviePosterNotifier, String?>(() {
      return SelectedMoviePosterNotifier();
    });

//toàn bộ state của màn hình được quản lý bằng Riverpod provider
//Ko cần dùng setState
//Tự động rebuild UI khi state thay đổi
class MainPage extends ConsumerWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    //Lấy controller để gọi các hàm xử lí (getMovies, updateSearchCategory,...)
    final mainPageDataController = ref.watch(
      mainPageDataControllerProvider.notifier,
    );

    //Lấy trạng thái MainPageData (movies, page, searchCategory, searchText)-> hiển thị UI
    final mainPageData = ref.watch(mainPageDataControllerProvider);

    //Lấy URL poster được chọn dể hiển thị bg
    final selectMoviePosterURL = ref.watch(selectedMoviePosterProvider);

    //Lấy notifier để cập nhật URL poster được chọn khi click vào movie
    final selectedMoviePosterNotifier = ref.watch(
      selectedMoviePosterProvider.notifier,
    );

    //Tạo controller cho TextField tìm kiếm
    final searchTextFieldController = TextEditingController();

    //Cập nhật giá trị ban đầu cho TextField từ mainPageData.searchText
    searchTextFieldController.text = mainPageData.searchText;

    //Xây dựng UI
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
    //Toàn bộ UI của MainPage
    return Container(
      color: Colors.black,
      width: deviceWidth,
      child: Stack(
        //stack để có thể đặt bg và fg chồng lên nhau
        children: [
          //Background widget (ảnh poster movie được chọn, hoặc màu đen nếu null)
          _backgroundWidget(deviceHeight, deviceWidth, selectMoviePosterURL),
          //Foreground widgets (toàn bộ UI chính)
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
    );
  }

  // Widget background hiển thị poster movie được chọn làm bg
  Widget _backgroundWidget(
    double deviceHeight,
    double deviceWidth,
    String? selectMoviePosterURL,
  ) {
    if (selectMoviePosterURL != null) {
      //Positioned.fill để lấp đầy toàn bộ không gian cha
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage(selectMoviePosterURL),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            //làm mở ảnh bg
            filter: ImageFilter.blur(
              sigmaX: 15.0,
              sigmaY: 15.0,
            ), //Độ mờ theo trục X,Y
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ), //lớp phủ đen mờ
            ),
          ),
        ),
      );
    } else {
      return Positioned.fill(child: Container(color: Colors.black));
    }
  }

  // Widget foreground chứa toàn bộ UI chính
  // gồm thanh tìm kiếm, chọn thể loại và danh sách phim
  // Được đặt trong SafeArea để tránh bị che khuất bởi tai thỏ, thanh trạng thái, viền cắt màn hình
  Widget _foregroundWidgets(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    SelectedMoviePosterNotifier notifier,
    TextEditingController searchTextFieldController,
  ) {
    return SafeArea(
      child: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            0,
            deviceHeight * 0.02,
            0,
            0,
          ), //padding trên(Tạo khoảng hở phía trên)
          width: deviceWidth * 0.88,
          child: Column(
            mainAxisSize: MainAxisSize.max, //chiếm toàn bộ chiều dọc
            mainAxisAlignment: MainAxisAlignment.start, //căn từ trên xuống
            crossAxisAlignment:
                CrossAxisAlignment.center, //căn giữa theo chiều ngang
            children: [
              _topBarWidget(
                //thanh tìm kiếm và chọn thể loại
                deviceHeight,
                deviceWidth,
                mainPageDataController,
                mainPageData,
                searchTextFieldController,
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ), //khoảng cách giữa top bar và danh sách phim
              Expanded(
                //Dùng Expanded để cho widget con chiếm toàn bộ không gian còn lại
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: deviceHeight * 0.01,
                  ), //khoảng cách trên dưới
                  child: _movieListViewWidget(
                    //danh sách phim
                    deviceHeight,
                    deviceWidth,
                    mainPageDataController,
                    mainPageData,
                    notifier,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget thanh tìm kiếm và chọn thể loại
  Widget _topBarWidget(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    TextEditingController searchTextFieldController,
  ) {
    return Container(
      height: deviceHeight * 0.08, //chiều cao thanh trên
      decoration: BoxDecoration(
        color: Colors.black54, //màu nền đen trong suốt
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max, //chiếm toàn bộ chiều ngang
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, //cách đều nhau
        crossAxisAlignment: CrossAxisAlignment.center, //căn giữa theo chiều dọc
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

  // Widget thanh tìm kiếm
  Widget _searchFieldWidget(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    TextEditingController searchTextFieldController,
  ) {
    final border = InputBorder.none; //không viền
    return Container(
      width: deviceWidth * 0.50, //chiếm 50% chiều ngang
      height: deviceHeight * 0.05, //chiều cao 5% chiều dọc
      child: TextField(
        controller: searchTextFieldController, //gán controller để quản lí text
        onSubmitted: (input) => mainPageDataController.updateSearchText(
          input,
        ), //gọi hàm cập nhật text khi nhấn enter
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          //trang trí cho TextField(ô nhập)
          focusedBorder: border, //viền khi được chọn
          border: border, //viền mặc định
          prefixIcon: Icon(Icons.search, color: Colors.white24),
          hintStyle: TextStyle(color: Colors.white54),
          filled: false, //không tô màu nền
          fillColor: Colors.white24, //màu nền nếu filled=true
          hintText: 'Search....',
        ),
      ),
    );
  }

  //  Widget chọn thể loại phim
  Widget _categorySelectionWidget(
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
  ) {
    return DropdownButton(
      //nút dropdown
      dropdownColor: Colors.black38,
      value: mainPageData.searchCategory, //giá trị hiện tại
      icon: Icon(Icons.menu, color: Colors.white24),
      underline: Container(height: 1, color: Colors.white24), //gạch chân
      onChanged: (value) {
        //khi chọn 1 mục trong dropdown
        if (value != null && value.toString().isNotEmpty) {
          //kiểm tra giá trị khác null và ko rỗng
          mainPageDataController.updateSearchCategory(
            value,
          ); //gọi hàm cập nhật thể loại
        }
      },
      items: [
        //danh sách mục trong dropdown
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

  // Widget danh sách phim
  Widget _movieListViewWidget(
    double deviceHeight,
    double deviceWidth,
    MainPageDataController mainPageDataController,
    MainPageData mainPageData,
    SelectedMoviePosterNotifier notifier,
  ) {
    final movies = mainPageData.movies; //lấy danh sách movies từ trạng thái

    if (movies.isNotEmpty) {
      return NotificationListener(
        //lắng nghe sự kiện cuộn
        onNotification: (onScrollNotification) {
          //khi có sự kiện cuộn
          if (onScrollNotification is ScrollEndNotification) {
            //Chỉ xử lí khi cuộn xong
            //kiểm tra đã cuộn đến cuối danh sách chưa
            final before =
                onScrollNotification.metrics.extentBefore; //độ dài đã cuộn
            final max = onScrollNotification
                .metrics
                .maxScrollExtent; //độ dài tối đa có thể cuộn
            if (before == max) {
              mainPageDataController.getMovies(); //gọi hàm lấy thêm movies
              return true; //đã xử lí sự kiện
            }
            return false; //chưa đến cuối danh sách
          }
          return false; //không xử lí các sự kiện khác
        },
        child: ListView.builder(
          //danh sách phim dạng cuộn
          itemCount: movies.length,
          itemBuilder: (context, count) {
            return Padding(
              padding: EdgeInsets.symmetric(
                //khoảng cách giữa các phần tử
                vertical: deviceHeight * 0.01, //khoảng cách trên dưới
                horizontal: 0, //khoảng cách trái phải
              ),
              child: GestureDetector(
                //bắt sự kiện bấm phim
                onTap: () {
                  notifier.setUrl(
                    movies[count].posterUrl(),
                  ); //cập nhật URL poster được chọn
                },
                child: MovieTile(
                  //hiển thị thông tin phim
                  movie: movies[count], //truyền movie hiện tại
                  height: deviceHeight * 0.20, //chiều cao tile
                  width: deviceWidth * 0.85, //chiều rộng tile
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Center(
        //hiển thị vòng tròn tải khi ko có movie nào
        child: CircularProgressIndicator(backgroundColor: Colors.white),
      );
    }
  }
}
