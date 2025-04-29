import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:app_stage_movie/core/widgets/custom_error_widget.dart';
import 'package:app_stage_movie/core/widgets/custom_loading.dart';
import 'package:app_stage_movie/core/widgets/empty_state_widget.dart';
import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/presentation/bloc/movie_cubit.dart';
import 'package:app_stage_movie/presentation/bloc/movie_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MovieListPage extends StatelessWidget {
  const MovieListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final movieCubit = context.read<MovieCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          BlocBuilder<MovieCubit, MovieState>(
            builder: (context, state) {
              final isFavoriteView =
                  state is MovieStateLoaded && state.showFavoritesOnly;

              return IconButton(
                icon: Icon(
                  isFavoriteView ? Icons.favorite : Icons.favorite_border,
                  color: isFavoriteView ? Colors.red : null,
                ),
                onPressed: movieCubit.toggleFavoriteView,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const _SearchBar(),
          const SizedBox(height: 8),
          const Expanded(child: _MovieListContent()),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final movieCubit = context.read<MovieCubit>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search movies...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: movieCubit.searchMoviesLocally,
      ),
    );
  }
}

class _MovieListContent extends StatelessWidget {
  const _MovieListContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        return switch (state) {
          MovieStateLoading() => const CustomLoading(),
          MovieStateError(:final message) => CustomErrorWidget(
              message: message,
              onRetry: context.read<MovieCubit>().fetchMovies,
            ),
          MovieStateLoaded(:final movies, :final filteredMovies) =>
            _buildMovieGrid(
              context,
              filteredMovies.isEmpty ? movies : filteredMovies,
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildMovieGrid(BuildContext context, List<Movie> movies) {
    if (movies.isEmpty) {
      return const EmptyStateWidget(message: 'No movies found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _MovieGridItem(movie: movies[index]);
      },
    );
  }
}

class _MovieGridItem extends StatelessWidget {
  final Movie movie;

  const _MovieGridItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    final movieCubit = context.read<MovieCubit>();

    return InkWell(
      onTap: () => movieCubit.openMovieDetail(context, movie.id),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageWithFavoriteIcon(context, movie),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithFavoriteIcon(BuildContext context, Movie movie) {
    final movieCubit = context.read<MovieCubit>();

    return Expanded(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              '${AppConstants.imageBaseUrl}${movie.posterPath}',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () => movieCubit.toggleFavorite(movie, context),
              child: Icon(
                movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: movie.isFavorite ? Colors.red : Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
