import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//models
import '../models/movie.dart';

//controllers
import '../controllers/wishlist_controller.dart';

class MovieTile extends ConsumerWidget {
  //hiển thị 1 ô thông tin phim
  final GetIt getIt = GetIt.instance;
  final double height;
  final double width;
  final Movie movie;

  MovieTile({required this.height, required this.width, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteMoviesProvider);
    final isFav = favourites.any((m) => m.id == movie.id);

    return Container(
      child: Row(
        mainAxisSize:
            MainAxisSize.max, //chiều ngang chiếm hết không gian có thể
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, //giữa các phần tử cách đều nhau
        crossAxisAlignment:
            CrossAxisAlignment.start, //căn phần tử theo đầu trên
        children: [
          _moviePosterWidget(movie.posterUrl()),
          _movieInfoWidget(context, isFav, ref),
        ],
      ),
    );
  }

  Widget _movieInfoWidget(BuildContext context, bool isFav, WidgetRef ref) {
    return Container(
      height: height, //chiều cao bằng với poster
      width: width * 0.63, //chiều rộng chiếm 63% chiều rộng tổng
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start, //căn từ trên xuống
        crossAxisAlignment: CrossAxisAlignment.start, //căn từ trái sang phải
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  movie.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 8),

              SizedBox(
                width: 68, // điều chỉnh theo cần thiết
                height: 36, // chiều cao cố định để không kéo Row
                child: Stack(
                  children: [
                    // Rating ở góc trên phải
                    Align(
                      //căn vị trí widget trong stack
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      // nút yêu thích ở góc dưới phải
                      right: 0,
                      bottom: -3,
                      child: GestureDetector(
                        //bắt sự kiện chạm
                        onTap: () async {
                          final ok = await ref
                              .read(favouriteMoviesProvider.notifier)
                              .toggleFavorite(movie);
                          final messenger = ScaffoldMessenger.of(context);
                          if (ok) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFav
                                      ? 'Removed from wishlist'
                                      : 'Added to wishlist',
                                ),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Could not update wishlist'),
                                duration: Duration(milliseconds: 1000),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.redAccent : Colors.white70,

                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            //hàng chứa thông tin phụ
            //  padding: EdgeInsets.fromLTRB(0, height * 0.02, 0, 0),
            child: Row(
              children: [
                Text(
                  '${movie.language.toUpperCase()} | R: ${movie.isAdult} | ${movie.releaseDate}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          //SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              //cho phép cuộn nếu text dài
              padding: EdgeInsets.fromLTRB(0, height * 0.07, 0, 0),
              child: Text(
                movie.description,
                maxLines: 9,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moviePosterWidget(String _imageURL) {
    return Container(
      height: height, //chiều cao poster
      width: width * 0.35, //chiều rộng poster chiếm 35% chiều rộng tổng
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(_imageURL)), //ảnh từ url
      ),
    );
  }
}
