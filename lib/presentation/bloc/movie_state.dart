import 'package:app_stage_movie/data/models/movie.dart';
import 'package:equatable/equatable.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieStateLoading extends MovieState {}

class MovieStateLoaded extends MovieState {
  final List<Movie> movies;
  final List<Movie> filteredMovies;
  final bool showFavoritesOnly;

  const MovieStateLoaded(this.movies, this.filteredMovies,
      {this.showFavoritesOnly = false});

  @override
  List<Object> get props => [movies, filteredMovies];
}

class MovieDetailStateLoaded extends MovieState {
  final Movie movie;

  const MovieDetailStateLoaded(this.movie);

  @override
  List<Object> get props => [movie];
}

class MovieStateError extends MovieState {
  final String message;

  const MovieStateError(this.message);

  @override
  List<Object> get props => [message];
}
