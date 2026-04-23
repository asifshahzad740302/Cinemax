class MovieModel {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final List<int> genreIds;
  final String releaseDate;
  final String overview;

  MovieModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.genreIds,
    required this.releaseDate,
    required this.overview,
  });

  String get ratingOutOfFive {
    double normalized = rating / 2;
    return normalized.toStringAsFixed(1);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "posterPath": posterPath,
      "backdropPath": backdropPath,
      "rating": rating,
      "genreIds": genreIds,
      "releaseDate": releaseDate,
      "overview": overview,
    };
  }
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    print("Firestore Data: $json");
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['posterPath'] ??
          (json['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
              : ''),
      backdropPath: json['backdropPath'] ??
          (json['backdrop_path'] != null
              ? 'https://image.tmdb.org/t/p/original${json['backdrop_path']}'
              : ''),
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : json['vote_average'] != null
          ? (json['vote_average'] as num).toDouble()
          : 0.0,
      genreIds: json['genreIds'] != null
          ? List<int>.from(json['genreIds'])
          : (json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : []),
      releaseDate: json['releaseDate'] ??
          json['release_date'] ??
          'N/A',
      // posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}' ?? '',
      // backdropPath: 'https://image.tmdb.org/t/p/original${json['backdrop_path']}' ?? '',
      // rating: (json['vote_average'] as num).toDouble(),
      // genreIds: List<int>.from(json['genre_ids'] ?? []), // Add this line
      // releaseDate: json['release_date'] ?? 'N/A', // Extracting date
      overview: json['overview'] ?? '',
    );
  }
}