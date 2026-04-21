import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax_fyp/Screens/MovieDetail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Management/MovieProvider.dart';
import '../Management/WishlistProvider.dart';
class WhichlistScreen extends StatefulWidget {
  const WhichlistScreen({super.key});

  @override
  State<WhichlistScreen> createState() => _WhichlistScreenState();
}

class _WhichlistScreenState extends State<WhichlistScreen> {
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D2B),
        leading: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xff252836),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          "Wishlist",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          if (provider.wishlistMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Your wishlist is empty",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Save your favorite movies here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.wishlistMovies.length,
            itemBuilder: (context, index) {
              final movie = provider.wishlistMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetail(movie: movie),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterPath,
                      width: width * .20,
                      height: height * .10,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  title: Text(
                    movie.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    movieProvider.getGenreName(movie.genreIds),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async =>
                        await provider.removeFromWishlist(movie),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
