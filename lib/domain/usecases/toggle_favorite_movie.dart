import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/domain/repository/movie_repository.dart';
import 'package:app_stage_movie/domain/usecases/usecase.dart';
import 'package:either_dart/either.dart';

class ToggleFavoriteMovie implements UseCase<void, Movie> {
  final MovieRepository repository;

  ToggleFavoriteMovie(this.repository);

  @override
  Future<Either<Failure, void>> call(Movie params) async {
    return await repository.toggleFavorite(params);
  }
}
