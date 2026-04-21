import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Management/TrailorController.dart';
import '../Model/Movie_Model.dart';
import '../Management/MovieProvider.dart';
import '../Management/WishlistProvider.dart';
import 'Trailor.dart';

class MovieDetail extends StatefulWidget {
  final MovieModel movie;
  const MovieDetail({super.key,required this.movie});
  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  final TrailerController controller = Get.find<TrailerController>();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final movieProv = Provider.of<MovieProvider>(context, listen: false);
      movieProv.fetchMovieDetails(widget.movie.id);
      movieProv.fetchMovieTrailer(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final movieProvider = Provider.of<MovieProvider>(context);
    int runtime = movieProvider.getMovieRuntime(movie.id);
    String genreName = movieProvider.getGenreName(movie.genreIds);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: height * 0.85,
                  width: double.maxFinite,
                  child: Opacity(
                    opacity: 0.3,
                    child: CachedNetworkImage(
                      imageUrl: movie.backdropPath,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey),
                      errorWidget: (_, __, ___) => Icon(Icons.error),
                    )

                  ),
                ),
                Container(
                  height: height * 0.85,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF1F1D2B)],
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.04,
                  left: width * 0.07,
                  right: width * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: height*.07,
                          padding: EdgeInsets.all(width * 0.02),
                          decoration: BoxDecoration(
                            color: Color(0xff252836),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: width * 0.05),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
                          ),
                        ),
                      ),

                      Consumer<WishlistProvider>(
                        builder: (context, wishlistProv, child) {
                          final isFav = wishlistProv.isFavorite(widget.movie);
                          return IconButton(
                            onPressed: () async {
                              await wishlistProv.toggleWishlist(widget.movie);
                            },
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: height * 0.10,
                  left: width * 0.25,
                  right: width * 0.25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterPath,
                      fit: BoxFit.cover,
                      height: height * .50,
                      placeholder: (_, __) => Container(color: Colors.grey),
                      errorWidget: (_, __, ___) => Icon(Icons.error),
                    )
                  ),
                ),
                Positioned(
                  top: height * 0.62,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.grey,),
                      const SizedBox(width: 4),
                      Text(movie.releaseDate.split('-')[0],
                          style: GoogleFonts.montserrat(fontSize:12,fontWeight:FontWeight.w500,color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: const Text("|", style: TextStyle(color: Colors.grey)),
                      ),
                      Icon(Icons.access_time, color: Colors.grey, size: width * 0.04),
                      const SizedBox(width: 4),
                      Text("${runtime > 0 ? runtime : '--'} Minutes", style: GoogleFonts.montserrat(fontSize:12,fontWeight:FontWeight.w500,color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: const Text("|", style: TextStyle(color: Colors.grey)),
                      ),
                      Icon(Icons.confirmation_number_outlined, color: Colors.grey, size: width * 0.04),
                      const SizedBox(width: 4),
                      Text(genreName, style: GoogleFonts.montserrat(fontSize:12,fontWeight:FontWeight.w500,color: Colors.grey)),
                    ],
                  ),
                ),
                Positioned(
                  top: height * 0.68,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 5),
                      Text(movie.ratingOutOfFive,style: GoogleFonts.montserrat(fontSize:12,fontWeight:FontWeight.w600,color: Colors.orange)),
                    ],
                  ),
                ),
                Positioned(
                  top: height * 0.75,
                  left: width * 0.06,
                  right: width * 0.06,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PlayScreen(movie: movie,)));
                          },
                          child: Container(
                            height: height * 0.07,
                            width: width*.25,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, color: Colors.white),
                                SizedBox(width: width * 0.02),
                                Text("Play",style: GoogleFonts.montserrat(fontSize:16,fontWeight:FontWeight.w500,color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(width: width * 0.04),
                      GestureDetector(
                        onTap: () {
                          if (movieProvider.trailerId != null) {
                            String fullTrailerUrl = "https://www.youtube.com/watch?v=${movieProvider.trailerId}";
                            controller.startDownload(fullTrailerUrl, widget.movie.id.toString());
                          } else {
                            Get.snackbar(
                              "Notice",
                              "Trailer not found for this movie",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Container(
                          height: height * 0.07,
                          width: height * 0.07,
                          decoration: const BoxDecoration(
                              color: Color(0xFF252836), shape: BoxShape.circle),
                          child: const Icon(Icons.file_download_outlined,
                              color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 8,right: 8,bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Story Line",style: GoogleFonts.montserrat(fontSize:16,
                      fontWeight:FontWeight.w600,color: Colors.white)),
                  SizedBox(height: height * 0.015),
                  RichText(
                    text: TextSpan(
                        style: GoogleFonts.montserrat(fontSize:14,fontWeight:FontWeight.w400,color: Color(0xffEBEBEF)),
                      children: [
                        TextSpan(
                          text: movie.overview),
                        TextSpan(
                          text: "More",style: GoogleFonts.montserrat(fontSize:12,
                            fontWeight:FontWeight.w500,color: Color(0xff12CDD9)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
