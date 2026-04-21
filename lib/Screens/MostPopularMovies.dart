import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Management/MovieProvider.dart';
import 'MovieDetail.dart';

class MostPopularMovies extends StatefulWidget {
  const MostPopularMovies({super.key});

  @override
  State<MostPopularMovies> createState() => _MostPopularMoviesState();
}

class _MostPopularMoviesState extends State<MostPopularMovies> {
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF1F1D2B),
      appBar: AppBar(
        backgroundColor: Color(0xff1f1d2b),
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
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
        ),
        centerTitle: true,
        title: Text(
          'Most Popular Movies',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: movieProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff12CDD9)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: movieProvider.filteredPopularMovies.length,
        itemBuilder: (context, index) {
          final movie = movieProvider.filteredPopularMovies[index];
          movieProvider.fetchMovieDetails(movie.id);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MovieDetail(movie: movie)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 150,
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: movie.posterPath,
                          fit: BoxFit.cover,
                          height: height * .20,
                          width: width*.25,
                          placeholder: (_, __) => Container(color: Colors.grey),
                          errorWidget: (_, __, ___) => Icon(Icons.error),
                        )
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1D2B).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFF8700), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                movie.ratingOutOfFive,
                                style: const TextStyle(color: Color(0xFFFF8700), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          movie.title,
                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 12),
                            const SizedBox(width: 4),
                            Text(movie.releaseDate.split('-')[0], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "${movieProvider.getMovieRuntime(movie.id)} Minutes",
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.movie, color: Colors.grey, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              movieProvider.getGenreName(movie.genreIds),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            const Text("|", style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Text("Movie", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
