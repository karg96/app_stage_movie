import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/core/widgets/custom_error_widget.dart';
import 'package:app_stage_movie/core/widgets/custom_loading.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/presentation/bloc/movie_cubit.dart';
import 'package:app_stage_movie/presentation/bloc/movie_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MovieDetailPage extends StatelessWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    // Trigger detail fetch on build
    final movieCubit = context.read<MovieCubit>()
      ..getMovieDetails(movieId);

    return BlocProvider.value(
      value: movieCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movie Details'),
        ),
        body: BlocBuilder<MovieCubit, MovieState>(
          builder: (context, state) {
            if (state is MovieStateLoading) {
              return const CustomLoading();
            }
            if (state is MovieStateError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<MovieCubit>()
                    .getMovieDetails(movieId),
              );
            }
            if (state is MovieDetailStateLoaded) {
              return _DetailContent(
                movie: state.movie,
                onToggleFavorite: () => context
                    .read<MovieCubit>()
                    .toggleFavorite(state.movie, context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Movie movie;
  final VoidCallback onToggleFavorite;

  const _DetailContent({
    required this.movie,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PosterImage(posterPath: movie.posterPath),
          const SizedBox(height: 16),
          _TitleSection(
            title: movie.title,
            isFavorite: movie.isFavorite,
            onToggle: onToggleFavorite,
          ),
          const SizedBox(height: 12),
          Text('Release Date: ${movie.releaseDate}'),
          const SizedBox(height: 4),
          Text('Rating: ${movie.voteAverage}/10'),
          const Divider(height: 32),
          Text(
            movie.overview,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  final String posterPath;

  const _PosterImage({required this.posterPath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        '${AppConstants.imageBaseUrl}$posterPath',
        height: 400,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image,
          size: 100,
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onToggle;

  const _TitleSection({
    required this.title,
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ],
    );
  }
}
