import 'package:app_stage_movie/core/utils/app_exceptions.dart';
import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:hive/hive.dart';

abstract class MovieLocalDataSource {
  Future<void> toggleFavorite(Movie movie);
  Future<List<Movie>> getFavoriteMovies();
  Future<bool> isFavorite(int movieId);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final Box<Movie> box;

  MovieLocalDataSourceImpl({required this.box});

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: AppConstants.cacheFailureMessage);
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      return box.containsKey(movieId);
    } catch (e) {
      throw CacheException(message: AppConstants.cacheFailureMessage);
    }
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    try {
      if (box.containsKey(movie.id)) {
        await box.delete(movie.id);
      } else {
        await box.put(movie.id, movie);
      }
    } catch (e) {
      throw CacheException(message: AppConstants.cacheFailureMessage);
    }
  }
}