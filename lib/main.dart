import 'package:app_stage_movie/data/models/movie.dart';
import 'package:app_stage_movie/presentation/bloc/movie_cubit.dart';
import 'package:app_stage_movie/presentation/pages/movie_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/di/injection_container.dart';
import 'core/utils/constants.dart';
final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(MovieAdapter());

  // Open Hive boxes
  await Hive.openBox<Movie>(AppConstants.favoritesBoxName);

  // Initialize dependency injection
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_)=> getIt<MovieCubit>()..fetchMovies(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        navigatorKey: navigatorKey,
        home: MovieListPage(),
      ),
    );
  }
}
