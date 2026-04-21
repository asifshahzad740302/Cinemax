import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax_fyp/Screens/DownloadScreen.dart';
import 'package:cinemax_fyp/Screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Management/MovieProvider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemax_fyp/Screens/whichlistScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Management/WishlistProvider.dart';
import 'MostPopularMovies.dart';
import 'MovieDetail.dart';
import 'SearchScreen.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isUserLoading = true;
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  ImageProvider? _getUserImage(String image) {
    if (image.isEmpty) return null;

    if (image.startsWith("http")) {
      return NetworkImage(image);
    }
    try {
      return MemoryImage(base64Decode(image));
    } catch (e) {
      print("Image error: $e");
      return null;
    }
  }

  Future<bool> checkInternet(BuildContext context) async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Please check your connection"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retry"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, DownloadsScreen() as String);
              },
              child: const Text("Go to Downloads"),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final wishlist = await Provider.of<WishlistProvider>(context, listen: false);
      wishlist.loadFromLocal();
      wishlist.loadWishlist();

      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      bool isOnline = await checkInternet(context);
      if (isOnline) {
        await movieProvider.fetchGenres();
        await movieProvider.fetchHomeData();
      } else {
        movieProvider.loadOfflineData();
      }
    });
  }
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF1F1D2B),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1D2B),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>ProfileScreen()));
            },
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircleAvatar(
                    child: CircularProgressIndicator(),
                  );
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;

                String image = data['image'] ?? "";

                return CircleAvatar(
                  radius: 25,
                  backgroundImage: _getUserImage(image),
                  child: image.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                );
              },
            ),
          ),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Text("Loading...",
                  style: TextStyle(color: Colors.white));
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            String name = data['name'] ?? "User";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white),
                ),
                Text(
                  'Let’s stream your favorite movie',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              ],
            );
          },
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => WhichlistScreen()));
                },
                child: Icon(Icons.favorite_outlined,color: Colors.white)),
          ),
        ],
      ),
      body: movieProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff12CDD9)))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _searchController,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen()));
                },
                onChanged: (value) {
                  Provider.of<MovieProvider>(context, listen: false).searchMovies(value);
                },
                style: GoogleFonts.montserrat(fontSize:14,
                    fontWeight:FontWeight.w500,color:Colors.grey),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xff252836),
                  prefixIcon: Icon(Icons.search,color:Colors.grey),
                  suffixIcon: Icon(Icons.filter,color: Colors.white,),
                  hintText: 'Search a title',
                  hintStyle: GoogleFonts.montserrat(fontSize:14,
                      fontWeight:FontWeight.w500,color:Colors.grey,),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              SizedBox(height: height*.02,),
              CarouselSlider.builder(
                itemCount: movieProvider.trendingMovies.length,
                itemBuilder: (BuildContext context, int Index, _) {
                  final movie = movieProvider.trendingMovies[Index];
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MovieDetail(movie: movie),
                            ),
                          );
                        },
                        child: Container(
                          height: height*.23,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: movie.backdropPath,
                                fit: BoxFit.cover,
                                width: width * .85,
                                placeholder: (_, __) => Container(color: Colors.grey),
                                errorWidget: (_, __, ___) => Icon(Icons.error),
                              )
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 35, left: 25,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:  [
                            Text(
                                movie.title,
                                maxLines: 3, style: GoogleFonts.montserrat(color: Colors.white,
                                fontWeight: FontWeight.bold, fontSize: 18)
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  viewportFraction: 2.0,
                  pauseAutoPlayOnTouch: true,
                  autoPlayInterval: Duration(seconds: 6),
                  aspectRatio: 16 / 6,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  onPageChanged: (index, _) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              SizedBox(height: height*.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(movieProvider.trendingMovies.length, (index) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    width: _currentIndex == index ? 8 : 4,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF12CDD9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              SizedBox(height:height*.02),
              Text('Categories',style: GoogleFonts.montserrat(fontSize: 16,
                  fontWeight: FontWeight.w600,color: Colors.white),),
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
                                fontSize: 10,color: isSelected ? Color(0xff12CDD9)  : Colors.white,),),),
                          ),
                        ),
                      );
                    }
                ),
              ),
              SizedBox(height: height*.02,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text('Most Popular',style: GoogleFonts.montserrat(fontWeight: FontWeight.w600,
                        fontSize: 16,color: Colors.grey)),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MostPopularMovies()));
                        },
                      child: Text('See All',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                          fontSize: 14,color: Color(0xff12CDD9))),
                          ),
                  ]
              ),
              SizedBox(height: height*.01,),
              movieProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : movieProvider.filteredPopularMovies.isEmpty
                  ? const Text("No movies found in this category", style: TextStyle(color: Colors.grey))
                  : SizedBox(
                height:height*.38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movieProvider.filteredPopularMovies.length,
                    itemBuilder: (BuildContext context, int index){
                      final movie = movieProvider.filteredPopularMovies[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => MovieDetail(movie: movie,))
                            );
                          },
                            child: Container(
                              height: height*.26,
                              width: width*.33,
                              decoration: BoxDecoration(
                                color: Color(0xff252836),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child:  CachedNetworkImage(
                                          imageUrl: movie.posterPath,
                                          fit: BoxFit.cover,
                                          height: height * .257,
                                          width: double.infinity,
                                          placeholder: (_, __) => Container(color: Colors.grey),
                                          errorWidget: (_, __, ___) => Icon(Icons.error),
                                        )
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xff252836),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, size: 12, color: Color(0xffFF8700),),
                                                SizedBox(width: 2),
                                                Text(movie.ratingOutOfFive, style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                                                    color: Color(0xffFF8700)),),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0,right:8,top: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            movie.title,
                                            maxLines: 2,
                                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600,
                                            fontSize: 12,color: Colors.white)),
                                        Text(
                                            movieProvider.getGenreName(movie.genreIds),
                                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                                            fontSize: 9,color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                      );
                    }
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
