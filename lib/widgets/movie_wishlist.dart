import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//models
import '../models/movie.dart';

//controllers
import '../controllers/wishlist_controller.dart';

class MovieWishlist extends ConsumerWidget {
  //hiển thị 1 ô thông tin phim
  final double height;
  final double width;
  final Movie movie;

  MovieWishlist({
    required this.height,
    required this.width,
    required this.movie,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _moviePosterWidget(movie.posterUrl()),
                const SizedBox(width: 12),
                _movieInfoWidget(ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _movieInfoWidget(WidgetRef ref) {
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
                      // nút xóa ở góc phải
                      right: 10,
                      bottom: -20,
                      child: IconButton(
                        onPressed: () {
                          //xóa phim khỏi danh sách yêu thích
                          ref
                              .read(favouriteMoviesProvider.notifier)
                              .removeFavorite(movie.id);
                        },
                        icon: Icon(Icons.delete, color: Colors.grey, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            //hàng chứa thông tin phụ
            children: [
              Text(
                '${movie.language.toUpperCase()} | R: ${movie.isAdult} | ${movie.releaseDate}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        _imageURL,
        height: height,
        width: width * 0.35,
        fit: BoxFit.cover,
      ),
    );
  }
}
