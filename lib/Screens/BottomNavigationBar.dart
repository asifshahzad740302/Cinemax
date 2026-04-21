import 'package:cinemax_fyp/Screens/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DownloadScreen.dart';
import 'Home.dart';
import 'SearchScreen.dart';
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int selectedindex=0;

  void itemTapped(int index){
    setState(() {
      selectedindex=index;
    });
  }
  List pages=[
    Home(),
    SearchScreen(),
    DownloadsScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.elementAt(selectedindex),
      bottomNavigationBar: BottomAppBar(
        child: CupertinoTabBar(
            currentIndex: selectedindex,
            activeColor: Color(0xff12CDD9),
            inactiveColor: Colors.grey,
            onTap: itemTapped,
            items: [
              BottomNavigationBarItem(
                  icon:    Icon(Icons.home),
                  label: 'Home'
              ),
              BottomNavigationBarItem(icon: Icon(Icons.search),
                  label: 'Search'
              ),
              BottomNavigationBarItem(icon: Icon(Icons.file_download_outlined),
                  label: 'Download'
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person),
                  label: 'Profile'
              ),
            ]
        ),
      ),
    );
  }
}
