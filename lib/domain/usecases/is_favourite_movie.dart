import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/domain/repository/movie_repository.dart';
import 'package:app_stage_movie/domain/usecases/usecase.dart';
import 'package:either_dart/either.dart';

class IsFavouriteMovie implements UseCase<bool, int> {
  final MovieRepository repository;

  IsFavouriteMovie(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return await repository.isFavorite(params);
  }


}