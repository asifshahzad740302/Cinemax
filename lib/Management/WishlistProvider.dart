import 'package:cinemax_fyp/Model/Movie_Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

class WishlistProvider with ChangeNotifier {
  final List<MovieModel> _wishlistMovies = [];

  List<MovieModel> get wishlistMovies => _wishlistMovies;
  final box = Hive.box('Cinemax');
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not logged in yet");
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .get();

    _wishlistMovies.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      _wishlistMovies.add(MovieModel(
          id: data['id'] ?? 0,
          title: data['title'] ?? '',
          posterPath: data['posterPath'] ?? '',
          backdropPath: data['backdropPath'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          genreIds: List<int>.from(data['genreIds'] ?? []),
          releaseDate: data['releaseDate'] ?? '',
          overview: data['overview'] ?? '',
      ));
    }
    saveToLocal();
    print("Wishlist Loaded: ${_wishlistMovies.length}");
    notifyListeners();
  }

  Future<void> addToWishlist(MovieModel movie) async {
    _wishlistMovies.add(movie);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("wishlist")
        .doc(movie.id.toString())
        .set(movie.toJson());


  }

  Future<void> removeFromWishlist(MovieModel movie) async {
    _wishlistMovies.removeWhere((item) => item.id == movie.id);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("wishlist")
        .doc(movie.id.toString())
        .delete();
  }
  void saveToLocal() {
    box.put('wishlist', _wishlistMovies.map((e) => e.toJson()).toList());
  }

  void loadFromLocal() {
    final data = box.get('wishlist', defaultValue: []);

    _wishlistMovies.clear();

    for (var item in data) {
      _wishlistMovies.add(MovieModel.fromJson(Map<String, dynamic>.from(item)));
    }

    notifyListeners();
  }

  Future<void> toggleWishlist(MovieModel movie) async{
    final isExist = _wishlistMovies.any((item) => item.id == movie.id);

    if (isExist) {
      await removeFromWishlist(movie);
    } else {
      await addToWishlist(movie);
    }
    saveToLocal();
  }

  bool isFavorite(MovieModel movie) {
    return _wishlistMovies.any((item) => item.id == movie.id);
  }
}