import 'package:app_stage_movie/core/error/failures.dart';
import 'package:either_dart/either.dart';

abstract class UseCase<Type, Params>{
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
