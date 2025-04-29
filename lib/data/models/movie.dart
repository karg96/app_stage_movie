import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(fieldRename: FieldRename.snake)
class Movie {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  @JsonKey(name: 'poster_path')
  final String posterPath;

  @HiveField(3)
  final String overview;

  @HiveField(4)
  final String releaseDate;

  @HiveField(5)
  final double voteAverage;

  @HiveField(6)
  final bool isFavorite;

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    this.isFavorite = false,
  });

  // JSON methods
  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);

  // copyWith
  Movie copyWith({
    int? id,
    String? title,
    String? posterPath,
    String? overview,
    String? releaseDate,
    double? voteAverage,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // equality and hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Movie &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              posterPath == other.posterPath &&
              overview == other.overview &&
              releaseDate == other.releaseDate &&
              voteAverage == other.voteAverage &&
              isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      posterPath.hashCode ^
      overview.hashCode ^
      releaseDate.hashCode ^
      voteAverage.hashCode ^
      isFavorite.hashCode;
}