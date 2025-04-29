class AppConstants {
  static const String appName = 'Movie App';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String apiKey = 'f1d11dcf6871d9e2dedc0a40252716c2'; // Replace with your API key

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  static const String noInternetMessage = 'No Internet Connection';
  static const String serverFailureMessage = 'Server Failure';
  static const String cacheFailureMessage = 'Cache Failure';
  static const String unexpectedErrorMessage = 'Unexpected Error';

  static const String favoritesBoxName = 'favorites';
}

class ApiConstants {
  static const String popularMovies = '/movie/popular';
  static const String movieDetail = '/movie/{movie_id}';
  static const String searchMovies = '/search/movie';
}
