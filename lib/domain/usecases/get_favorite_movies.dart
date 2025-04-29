import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/domain/repository/movie_repository.dart';
import 'package:app_stage_movie/domain/usecases/usecase.dart';
import 'package:either_dart/either.dart';

class GetFavoriteMovies implements UseCase<List<Movie>, NoParams> {
  final MovieRepository repository;

  GetFavoriteMovies(this.repository);

  @override
  Future<Either<Failure, List<Movie>>> call(NoParams params) async{
    return await repository.getFavoriteMovies();
  }


}