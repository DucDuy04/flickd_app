//package
import 'package:get_it/get_it.dart';

//models
import '../models/app_config.dart';

class Movie {
  final int id;
  final String name;
  final String language;
  final bool isAdult;
  final String description;
  final String posterPath;
  final String backdropPath;
  final num rating;
  final String releaseDate;

  Movie({
    required this.id,
    required this.name,
    required this.language,
    required this.isAdult,
    required this.description,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> _json) {
    return Movie(
      id: _json['id'] ?? 0,
      name: _json['title'] ?? 'Unknown',
      language: _json['original_language'] ?? 'en',
      isAdult: _json['adult'] ?? false,
      description: _json['overview'] ?? 'No description available',
      posterPath: _json['poster_path'] ?? '',
      backdropPath: _json['backdrop_path'] ?? '',
      rating: _json['vote_average'] ?? 0.0,
      releaseDate: _json['release_date'] ?? 'Unknown',
    );
  }

  String posterUrl() {
    final AppConfig _appConfig = GetIt.instance<AppConfig>();
    return '${_appConfig.BASE_IMAGE_API_URL}${this.posterPath}';
  }
}
