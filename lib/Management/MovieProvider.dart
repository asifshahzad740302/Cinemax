import 'dart:convert';
import 'package:cinemax_fyp/Model/Movie_Model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class MovieProvider extends ChangeNotifier {
  final String _apiKey = "fd620a733c2625c7ea268c712f7d9fcd";

  List<MovieModel> _trendingMovies = [];
  List<MovieModel> _popularMovies = [];
  bool _isLoading = false;
  final box = Hive.box('Cinemax');
  String? _error;

  Map<int, int> _movieRuntimes = {};
  List<MovieModel> get trendingMovies => _trendingMovies;
  List<MovieModel> get popularMovies => _popularMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<int, String> _genreMap = {};
  int getMovieRuntime(int movieId) => _movieRuntimes[movieId] ?? 0;

  String getGenreName(List<int> ids) {
    if (ids.isEmpty || _genreMap.isEmpty) return "Movie";
    return _genreMap[ids[0]] ?? "Movie";
  }

  Future<void> fetchMovieDetails(int movieId) async {
    if (_movieRuntimes.containsKey(movieId)) return;

    try {
      final response = await http.get(
          Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey')
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _movieRuntimes[movieId] = data['runtime'];
        notifyListeners();
      }
      else{
        print('something is missing');
      }
    } catch (e) {
      print("Detail fetch error: $e");
    }
  }

  Future<void> fetchGenres() async {
    try {
      final res = await http.get(Uri.parse('https://api.themoviedb.org/3/genre/movie/list?api_key=$_apiKey'));
      if (res.statusCode == 200) {
        final List genres = jsonDecode(res.body)['genres'];
        _genreMap = {for (var g in genres) g['id']: g['name']};
        box.put('genres', _genreMap);
        notifyListeners();
      }
      else{
        loadOfflineData();
      }
    } catch (e) {
        loadOfflineData();
    }
  }

  void loadOfflineData() {
    try {
      final trendingData = box.get('trending');
      final popularData = box.get('popular');
      final genreData = box.get('genres');

      if (trendingData != null) {
        _trendingMovies = (trendingData as List)
            .map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (popularData != null) {
        _popularMovies = (popularData as List)
            .map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (genreData != null) {
        _genreMap = Map<int, String>.from(genreData);
      }

      notifyListeners();
    } catch (e) {
      print("Offline load error: $e");
    }
  }

  void saveToHive() {
    try {
      box.put('trending', _trendingMovies.map((e) => e.toJson()).toList());
      box.put('popular', _popularMovies.map((e) => e.toJson()).toList());
      box.put('genres', _genreMap);
    } catch (e) {
      print("Hive save error: $e");
    }
  }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trendingRes = await http.get(Uri.parse('https://api.themoviedb.org/3/trending/movie/day?api_key=$_apiKey'));
      final popularRes = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=$_apiKey'));

      if (trendingRes.statusCode == 200 && popularRes.statusCode == 200) {
        _trendingMovies = (jsonDecode(trendingRes.body)['results'] as List)
            .map((m) => MovieModel.fromJson(m)).toList();
        _popularMovies = (jsonDecode(popularRes.body)['results'] as List)
            .map((m) => MovieModel.fromJson(m)).toList();
        saveToHive();
      } else {
        _error = "Server Error";
        loadOfflineData();
      }
    } catch (e) {
      _error = 'No Internet Connection';
      loadOfflineData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  int _selectedGenreId = -1;
  int get selectedGenreId => _selectedGenreId;

  List<MovieModel> get filteredPopularMovies {
    if (_selectedGenreId == -1) return _popularMovies;
    return _popularMovies.where((movie) => movie.genreIds.contains(_selectedGenreId)).toList();
  }

  Future<void> setGenre(int id) async {
    _selectedGenreId = id;
    _isLoading = true;
    notifyListeners();

    try {
      Uri url;
      if (id == -1) {
        url = Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=$_apiKey');
      } else {
        url = Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=$_apiKey&with_genres=$id');
      }

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List results = jsonDecode(res.body)['results'];
        _popularMovies = results.map((m) => MovieModel.fromJson(m)).toList();
      }
      else{
        _popularMovies = [];
      }
    } catch (e) {
      print("Genre Fetch Error: $e");
      _popularMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<int, String> get genreMap => _genreMap;

  List<MovieModel> searchResults = [];
  String lastQuery = "";

  Future<List<MovieModel>> searchMovies(String query) async {
    lastQuery = query;
    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return [];
    }
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List list = jsonDecode(response.body)['results'];
        searchResults = list.map((e) => MovieModel.fromJson(e)).toList();
        box.put('search_$query', searchResults.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      print('Offline Search Triggered');
      final allMovies = [..._popularMovies, ..._trendingMovies];
      searchResults = allMovies.where((movie) {
        return movie.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    _isLoading = false;
    notifyListeners();
    return searchResults;
  }

  List<MovieModel> get filteredSearchResults {
    if (_selectedGenreId == -1) return searchResults;

    return searchResults.where((movie) {
      return movie.genreIds.contains(_selectedGenreId);
    }).toList();
  }

  List<String> _movieGallery = [];
  List<String> get movieGallery => _movieGallery;

  Future<void> fetchMovieImages(int movieId) async {
    _movieGallery = [];
    try {
      final response = await http.get(
          Uri.parse('https://api.themoviedb.org/3/movie/$movieId/images?api_key=$_apiKey')
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List backdrops = data['backdrops'];
        _movieGallery = backdrops.take(10).map((i) => i['file_path'].toString()).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gallery fetch error: $e");
    }
  }

  String? _trailerId;
  String? get trailerId => _trailerId;

Future<void> fetchMovieTrailer(int movieId) async {
  _trailerId = null;
  try {
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$_apiKey')
    );
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      
      final trailer = results.firstWhere(
        (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
        orElse: () => results.isNotEmpty ? results[0] : null,
      );

      if (trailer != null) {
        _trailerId = trailer['key'];
        notifyListeners();
      }
    }
  } catch (e) {
    print("Trailer Fetch Error: $e");
  }
}
}