import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Management/MovieProvider.dart';
import '../Management/TrailorController.dart';
import '../Model/Movie_Model.dart';
import 'Trailor.dart';

class DownloadsScreen extends StatelessWidget {
  final TrailerController controller = Get.find<TrailerController>();

  @override
  Widget build(BuildContext context) {
    final movieProv = Provider.of<MovieProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        title: Text("My Downloads",style: GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Obx(() => controller.isDownloading.value
              ? LinearProgressIndicator(
            value: controller.progress.value,
            color: const Color(0xff12CDD9),)
              : SizedBox.shrink()),

          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.downloadedFiles.length,
              itemBuilder: (context, index) {
                final file = File(controller.downloadedFiles[index].path);
                final String fileName = file.path.split('/').last;
                final int movieId = int.tryParse(fileName.split('.').first) ?? 0;
                MovieModel? realMovie;
                try {
                  realMovie = [...movieProv.popularMovies,
                  ...movieProv.trendingMovies]
                      .firstWhere((m) => m.id == movieId);
                } catch (e) { realMovie = null; }
                return Card(
                  color: const Color(0xFF252836),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: realMovie != null
                          ? CachedNetworkImage(
                        imageUrl: realMovie.posterPath,
                        fit: BoxFit.cover,
                        width: 100,
                        placeholder: (_, __) => Container(color: Colors.grey),
                        errorWidget: (_, __, ___) => Icon(Icons.error),
                      )
                          : Container(width: 60, color: Colors.grey[900], child: const Icon(Icons.movie)),
                    ),
                    title: Text(realMovie?.title.toString() ?? "Movie $movieId",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(realMovie != null ? movieProv.getGenreName(realMovie.genreIds) : "Offline",
                        style: const TextStyle(color: Color(0xff12CDD9))),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => controller.deleteTrailer(file.path),
                    ),
                    onTap: () {
                      Get.to(() => PlayScreen(
                        file: file,
                        movie: realMovie ?? MovieModel(
                          id: movieId, title: "Trailer $movieId", posterPath: "", backdropPath: "",
                          rating: 0.0, genreIds: [], releaseDate: "Offline", overview: "Downloaded Content",
                        ),
                      ));
                    },
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
