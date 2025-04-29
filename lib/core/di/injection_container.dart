import 'package:app_stage_movie/core/network/dio_client.dart';
import 'package:app_stage_movie/core/network/network_info.dart';
import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/data/datasources/local/movie_local_datasource.dart';
import 'package:app_stage_movie/data/datasources/remote/movie_remote_datasource.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/data/repositories/movie_repository_impl.dart';
import 'package:app_stage_movie/domain/repository/movie_repository.dart';
import 'package:app_stage_movie/domain/usecases/get_favorite_movies.dart';
import 'package:app_stage_movie/domain/usecases/get_movie_detail.dart';
import 'package:app_stage_movie/domain/usecases/get_movies.dart';
import 'package:app_stage_movie/domain/usecases/is_favourite_movie.dart';
import 'package:app_stage_movie/domain/usecases/toggle_favorite_movie.dart';
import 'package:app_stage_movie/presentation/bloc/movie_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Dio
  getIt.registerSingleton<Dio>(Dio());

  // ApiClient
  getIt.registerSingleton<DioClient>(DioClient(dio: getIt<Dio>()));

  // Hive
  getIt.registerSingleton<Box<Movie>>(
    Hive.box<Movie>(AppConstants.favoritesBoxName),
  );

  // Data sources
  getIt.registerSingleton<MovieRemoteDataSource>(
    MovieRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerSingleton<MovieLocalDataSource>(
    MovieLocalDataSourceImpl(box: getIt<Box<Movie>>()),
  );

  // Network info
  getIt.registerSingleton<NetworkInfo>(
    NetworkInfoImpl(Connectivity()),
  );

  // Repository
  getIt.registerSingleton<MovieRepository>(
    MovieRepositoryImpl(
      remoteDataSource: getIt<MovieRemoteDataSource>(),
      localDataSource: getIt<MovieLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerSingleton<GetMovies>(
    GetMovies(getIt<MovieRepository>()),
  );
  getIt.registerSingleton<GetMovieDetail>(
    GetMovieDetail(getIt<MovieRepository>()),
  );

  getIt.registerSingleton<GetFavoriteMovies>(
    GetFavoriteMovies(getIt<MovieRepository>()),
  );
  getIt.registerSingleton<ToggleFavoriteMovie>(
    ToggleFavoriteMovie(getIt<MovieRepository>()),
  );
  getIt.registerSingleton<IsFavouriteMovie>(
    IsFavouriteMovie(getIt<MovieRepository>()),
  );

  // Bloc
  getIt.registerFactory<MovieCubit>(
    () => MovieCubit(
      getMoviesUseCase: getIt<GetMovies>(),
      getMovieDetailUseCase: getIt<GetMovieDetail>(),
      getFavoriteMoviesUseCase: getIt<GetFavoriteMovies>(),
      toggleFavoriteMovieUseCase: getIt<ToggleFavoriteMovie>(),
      isFavoriteMovieUseCase: getIt<IsFavouriteMovie>(),
    ),
  );
}
