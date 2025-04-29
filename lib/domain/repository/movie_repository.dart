import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:either_dart/either.dart';


abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getPopularMovies();
  Future<Either<Failure, Movie>> getMovieDetail(int id);
  Future<Either<Failure, List<Movie>>> getFavoriteMovies();
  Future<Either<Failure, void>> toggleFavorite(Movie movie);
  Future<Either<Failure, bool>> isFavorite(int movieId);
}