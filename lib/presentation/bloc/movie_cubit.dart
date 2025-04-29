import 'package:app_stage_movie/core/error/failures.dart';
import 'package:app_stage_movie/core/utils/app_utils.dart';
import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/domain/usecases/get_favorite_movies.dart';
import 'package:app_stage_movie/domain/usecases/get_movie_detail.dart';
import 'package:app_stage_movie/domain/usecases/get_movies.dart';
import 'package:app_stage_movie/domain/usecases/is_favourite_movie.dart';
import 'package:app_stage_movie/domain/usecases/toggle_favorite_movie.dart';
import 'package:app_stage_movie/domain/usecases/usecase.dart';
import 'package:app_stage_movie/main.dart';
import 'package:app_stage_movie/presentation/pages/movie_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  final GetMovies getMoviesUseCase;
  final GetMovieDetail getMovieDetailUseCase;
  final GetFavoriteMovies getFavoriteMoviesUseCase;
  final ToggleFavoriteMovie toggleFavoriteMovieUseCase;
  final IsFavouriteMovie isFavoriteMovieUseCase;

  MovieCubit({
    required this.getMoviesUseCase,
    required this.getMovieDetailUseCase,
    required this.getFavoriteMoviesUseCase,
    required this.toggleFavoriteMovieUseCase,
    required this.isFavoriteMovieUseCase,
  }) : super(MovieStateLoading()){
    fetchMovies();
  }

  // Fetch popular movies
  Future<void> fetchMovies() async {
    final result = await getMoviesUseCase(NoParams());
    result.fold(
      (failure) => emit(MovieStateError(_mapFailureToMessage(failure))),
      (movies) => emit(MovieStateLoaded(movies, [])),
    );
  }

  // Toggle favorite and update state accordingly
  Future<void> toggleFavorite(Movie movie, BuildContext context) async {
    final updatedMovie = movie.copyWith(isFavorite: !movie.isFavorite);
    final result = await toggleFavoriteMovieUseCase(updatedMovie);

    result.fold(
      (failure) => AppUtils.showSnackBar(
          context.mounted ? context : navigatorKey.currentContext!,
          _mapFailureToMessage(failure)),
      (_) {
        if (state is MovieStateLoaded) {
          final currentState = state as MovieStateLoaded;
          final updatedMovies = currentState.movies.map((m) {
            return m.id == movie.id ? updatedMovie : m;
          }).toList();
          _emitUpdatedMovieState(updatedMovies,
              showFavoritesOnly: currentState.showFavoritesOnly);
        } else if (state is MovieDetailStateLoaded) {
          emit(MovieDetailStateLoaded(updatedMovie));
        }
      },
    );
  }

  // Toggle view between all movies and favorites only
  Future<void> toggleFavoriteView() async {
    final currentState = state;
    if (currentState is! MovieStateLoaded) return;

    final showFavoritesOnly = !currentState.showFavoritesOnly;
    if (showFavoritesOnly) {
      final result = await getFavoriteMoviesUseCase(NoParams());
      result.fold(
        (failure) => emit(MovieStateError(_mapFailureToMessage(failure))),
        (favorites) => emit(MovieStateLoaded(
          currentState.movies,
          favorites,
          showFavoritesOnly: true,
        )),
      );
    } else {
      emit(MovieStateLoaded(currentState.movies, [], showFavoritesOnly: false));
    }
  }

  // Get movie details and sync with favorite status
  Future<void> getMovieDetails(int id) async {
    emit(MovieStateLoading());

    final result = await getMovieDetailUseCase(id);
    result.fold(
      (failure) => emit(MovieStateError(_mapFailureToMessage(failure))),
      (movie) async {
        final isFavorite = await _isFavorite(id);
        emit(MovieDetailStateLoaded(movie.copyWith(isFavorite: isFavorite)));
      },
    );
  }

  // Search movies locally based on query string
  void searchMoviesLocally(String query) {
    final currentState = state;
    if (currentState is! MovieStateLoaded) return;

    if (query.trim().isEmpty) {
      _emitUpdatedMovieState(
        currentState.movies,
        showFavoritesOnly: currentState.showFavoritesOnly,
      );
      return;
    }

    final filteredMovies = currentState.movies
        .where((movie) =>
            movie.title.toLowerCase().contains(query.toLowerCase().trim()))
        .toList();

    emit(MovieStateLoaded(
      currentState.movies,
      filteredMovies,
      showFavoritesOnly: currentState.showFavoritesOnly,
    ));
  }

  // Emit updated movie list with favorites filtering if needed
  void _emitUpdatedMovieState(List<Movie> updatedMovies,
      {required bool showFavoritesOnly}) {
    final filteredMovies = showFavoritesOnly
        ? updatedMovies.where((m) => m.isFavorite).toList()
        : <Movie>[];
    emit(MovieStateLoaded(
      updatedMovies,
      filteredMovies,
      showFavoritesOnly: showFavoritesOnly,
    ));
  }

  // Check if movie is marked favorite
  Future<bool> _isFavorite(int id) async {
    final result = await isFavoriteMovieUseCase(id);
    return result.fold((_) => false, (isFav) => isFav);
  }

  void openMovieDetail(BuildContext context, int movieId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: this,
          child: MovieDetailPage(movieId: movieId),
        ),
      ),
    );
    fetchMovies(); // side effect stays here
  }

  // Map domain failures to UI-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return AppConstants.serverFailureMessage;
      case CacheFailure _:
        return AppConstants.cacheFailureMessage;
      case NoInternetFailure _:
        return AppConstants.noInternetMessage;
      default:
        return AppConstants.unexpectedErrorMessage;
    }
  }
}
