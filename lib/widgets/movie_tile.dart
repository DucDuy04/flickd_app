import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//models
import '../models/movie.dart';

class MovieTile extends StatelessWidget {
  final GetIt getIt = GetIt.instance;
  final double height;
  final double width;
  final Movie movie;

  MovieTile({required this.height, required this.width, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_moviePosterWidget(movie.posterUrl()), _movieInfoWidget()],
      ),
    );
  }

  Widget _movieInfoWidget() {
    return Container(
      height: height,
      width: width * 0.63,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        movie.rating.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                    // IconButton(
                    //   padding: EdgeInsets.zero,
                    //   constraints: BoxConstraints(),
                    //   icon: Icon(
                    //     isFavourite ? Icons.favorite : Icons.favorite_border,
                    //     color: isFavourite ? Colors.red : Colors.white70,
                    //     size: 22,
                    //   ),
                    //   tooltip: isFavourite
                    //       ? 'Remove from favorites'
                    //       : 'Add to favorites',
                    //   onPressed: () {
                    //     ref.read(favouritesProvider.notifier).toggle(movie.id);
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //         content: Text(
                    //           isFavourite
                    //               ? 'Removed from favorites'
                    //               : 'Added to favorites',
                    //         ),
                    //         duration: Duration(milliseconds: 700),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, height * 0.02, 0, 0),
            child: Text(
              '${movie.language.toUpperCase()} | R: ${movie.isAdult} | ${movie.releaseDate}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(0, height * 0.07, 0, 0),
                child: Text(
                  movie.description,
                  maxLines: 9,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moviePosterWidget(String _imageURL) {
    return Container(
      height: height,
      width: width * 0.35,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(_imageURL)),
      ),
    );
  }
}
