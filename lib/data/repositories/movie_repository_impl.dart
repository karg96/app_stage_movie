import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/core/network/network_info.dart';
import 'package:app_stage_movie/core/utils/app_exceptions.dart';
import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/data/datasources/local/movie_local_datasource.dart';
import 'package:app_stage_movie/data/datasources/remote/movie_remote_datasource.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/domain/repository/movie_repository.dart';
import 'package:either_dart/either.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;
  final MovieLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  MovieRepositoryImpl({
    required MovieRemoteDataSource remoteDataSource,
    required MovieLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteMovies = await _remoteDataSource.getPopularMovies();
        await _syncFavoritesStatus(remoteMovies);
        return Right(remoteMovies);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    return await _getLocalFavoritesAsFallback();
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetail(int id) async {
    if (!await _networkInfo.isConnected) {
      return Left(NoInternetFailure(AppConstants.noInternetMessage));
    }

    try {
      final remoteMovie = await _remoteDataSource.getMovieDetail(id);
      final isFavorite = await _localDataSource.isFavorite(id);
      return Right(remoteMovie.copyWith(isFavorite: isFavorite));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getFavoriteMovies() async {
    try {
      final favorites = await _localDataSource.getFavoriteMovies();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(Movie movie) async {
    try {
      await _localDataSource.toggleFavorite(movie);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async {
    try {
      final isFav = await _localDataSource.isFavorite(movieId);
      return Right(isFav);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  Future<void> _syncFavoritesStatus(List<Movie> movies) async {
    final favoriteIds = (await _localDataSource.getFavoriteMovies())
        .map((movie) => movie.id)
        .toSet();

    for (var i = 0; i < movies.length; i++) {
      if (favoriteIds.contains(movies[i].id)) {
        movies[i] = movies[i].copyWith(isFavorite: true);
      }
    }
  }

  Future<Either<Failure, List<Movie>>> _getLocalFavoritesAsFallback() async {
    try {
      final favorites = await _localDataSource.getFavoriteMovies();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}