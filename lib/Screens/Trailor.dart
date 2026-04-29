import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Model/Movie_Model.dart';
import '../Management/MovieProvider.dart';

class PlayScreen extends StatefulWidget {
  final File? file;

  final MovieModel movie;
  const PlayScreen({super.key, required this.movie, this.file});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool isOffline = false;



  @override
  void initState() {
    super.initState();
    _checkOfflineAndInitialize();
    }

  Future<void> _checkOfflineAndInitialize() async {
    final movieProv = Provider.of<MovieProvider>(context, listen: false);

    final dir = await getApplicationDocumentsDirectory();
    final localFile = File("${dir.path}/${widget.movie.id}.mp4");
      if (await localFile.exists()) {
        setState(() => isOffline = true);
        _videoController = VideoPlayerController.file(localFile);
        await _videoController!.initialize();
        _videoController!.play();
        setState(() {});
      } else {
        setState(() => isOffline = false);
      movieProv.fetchMovieTrailer(widget.movie.id).then((_) {
        if (movieProv.trailerId != null) {
          setState(() {
            _youtubeController = YoutubePlayerController(
              initialVideoId: movieProv.trailerId!,
              flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
            );
          });
        }
      });
    }
    movieProv.fetchMovieImages(widget.movie.id);
  }
  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final movieProv = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(movie.title, style: GoogleFonts.montserrat(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: isOffline
                  ? _buildLocalPlayer()
                  : _buildYoutubePlayer(movieProv),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(movie.releaseDate, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 20),
                      const Icon(Icons.movie, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(movieProv.getGenreName(movie.genreIds), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text("Synopsis",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(movie.overview, 
                      style: GoogleFonts.montserrat(color: Colors.white70, height: 1.5, fontSize: 14)),

                  const SizedBox(height: 24),

                  Text("Gallery",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 12),
                  movieProv.movieGallery.isEmpty
                      ? const Center(child: Icon(Icons.broken_image, size: 50, color: Color(0xff252836)))
                      : SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movieProv.movieGallery.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    "https://image.tmdb.org/t/p/w300${movieProv.movieGallery[index]}",
                                    width: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              );
                            },
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

  Widget _buildLocalPlayer() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            if (!_videoController!.value.isPlaying)
              const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator(color: Color(0xff12CDD9)));
  }

  Widget _buildYoutubePlayer(MovieProvider movieProv) {
    if (_youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xff12CDD9),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xff12CDD9),
            handleColor: Color(0xff12CDD9),
          ),
      );
    } else if (movieProv.trailerId == null && !movieProv.isLoading) {
      return Container(color: Colors.black, child: const Center(child: Text("No Trailer Available", style: TextStyle(color: Colors.white))));
    }
    return const Center(child: CircularProgressIndicator(color: Color(0xff12CDD9)));
  }

}
