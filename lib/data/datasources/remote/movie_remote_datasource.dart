import 'package:app_stage_movie/core/network/dio_client.dart';
import 'package:app_stage_movie/core/utils/app_exceptions.dart';
import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/data/models/movie.dart';

abstract class MovieRemoteDataSource {
  Future<List<Movie>> getPopularMovies();

  Future<Movie> getMovieDetail(int id);

  Future<List<Movie>> searchMovies(String query);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  MovieRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await dioClient.get(ApiConstants.popularMovies);
      return (response['results'] as List)
          .map((json) => Movie.fromJson(json))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to load popular movies');
    }
  }

  @override
  Future<Movie> getMovieDetail(int id) async {
    try {
      final response = await dioClient.get(
        ApiConstants.movieDetail.replaceFirst('{movie_id}', id.toString()),
      );
      return Movie.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to load movie details');
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await dioClient.get(
        ApiConstants.searchMovies,
        params: {'query': query},
      );
      return (response['results'] as List)
          .map((json) => Movie.fromJson(json))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to search movies');
    }
  }
}
