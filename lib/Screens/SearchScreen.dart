import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Model/Movie_Model.dart';
import '../Management/MovieProvider.dart';
import 'MovieDetail.dart';

class SearchScreen extends StatefulWidget {
  final MovieModel? movie;
  const SearchScreen({super.key, this.movie});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF1F1D2B),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0,right: 8,left: 8,bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _searchController,
              onChanged: (value) {
                movieProvider.searchMovies(value);
              },
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xff252836),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Type title, categories, years, etc',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            SizedBox(height:height*.02),
            SizedBox(
              height:height*.07,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movieProvider.genreMap.length + 1,
                  itemBuilder: (BuildContext context, int index){
                    int genreId = index == 0 ? -1 : movieProvider.genreMap.keys.elementAt(index - 1);
                    String genreName = index == 0 ? "All" : movieProvider.genreMap.values.elementAt(index - 1);
                    bool isSelected = movieProvider.selectedGenreId == genreId;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => movieProvider.setGenre(genreId),
                        child: Container(
                          height: height*.08,
                          width: width*.25,
                          decoration: BoxDecoration(
                            color: Color(0xff252836),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child:
                          Text(genreName,
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                              fontSize: 10,color: isSelected ? Color(0xff12CDD9)  : Colors.white,),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),
            SizedBox(height: height * .02),
            Expanded(
              child: SingleChildScrollView(
                child: Consumer<MovieProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff12CDD9),
                        ),
                      );
                    }
                    if (provider.lastQuery.isEmpty) {
                      return buildInitialSearchUI(height, width, movieProvider);
                    }
                    if (provider.lastQuery.isNotEmpty && provider.searchResults.isEmpty) {
                      return buildNotFoundUI(height);
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.filteredSearchResults.length,
                      itemBuilder: (context, index) {
                        final movie = provider.filteredSearchResults[index];
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          provider.fetchMovieDetails(movie.id);
                        });
                        return MovieResultTile(
                          movie: movie,
                          height: height,
                          width: width,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildInitialSearchUI(
    double height,
    double width,
    MovieProvider movieProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... Put your existing Categories ListView.builder here ...
        // ... Put your existing 'Today' Section here ...
        // ... Put your existing 'Recommend for you' Row here ...
      ],
    );
  }

  Widget buildNotFoundUI(double height) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.2),
          const Icon(Icons.search_off, size: 100, color: Color(0xff12CDD9)),
          const SizedBox(height: 20),
          Text(
            'We Are Sorry, We Can \nNot Find The Movie :(',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget MovieResultTile({
    required MovieModel movie,
    required double height,
    required double width,
  }) {
    final provider = Provider.of<MovieProvider>(context, listen: true);
    int runtime = provider.getMovieRuntime(movie.id);
    String genreName = provider.getGenreName(movie.genreIds);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieDetail(movie: movie)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: movie.posterPath,
                    fit: BoxFit.cover,
                    height: height * .18,
                    width: width * .30,
                    memCacheWidth: 300,
                    maxHeightDiskCache: 600,
                    placeholder: (_, __) => Container(color: Colors.grey),
                    errorWidget: (_, __, ___) => Icon(Icons.error),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff252836),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 12),
                        SizedBox(width: 4),
                        Text(
                          movie.ratingOutOfFive,
                          style: GoogleFonts.montserrat(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: width * .02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height * .01),
                  Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.grey),
                      SizedBox(width: width * .02),
                      Text(
                        movie.releaseDate,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * .01),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey),
                      SizedBox(width: width * .02),
                      Text(
                        '${runtime > 0 ? runtime : '--'} Minutes',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * .01),
                  Row(
                    children: [
                      Icon(Icons.local_movies, color: Colors.grey),
                      SizedBox(width: width * .02),
                      Text(
                        genreName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        ' | ',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(color: Color(0xff696974)),
                      ),
                      Text(
                        'Movie',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
