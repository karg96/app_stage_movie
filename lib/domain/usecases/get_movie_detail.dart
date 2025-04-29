import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/domain/repository/movie_repository.dart';
import 'package:app_stage_movie/domain/usecases/usecase.dart';
import 'package:either_dart/either.dart';

class GetMovieDetail implements UseCase<Movie, int> {
  final MovieRepository repository;

  GetMovieDetail(this.repository);

  @override
  Future<Either<Failure, Movie>> call(int params) async {
    return await repository.getMovieDetail(params);
  }
}
