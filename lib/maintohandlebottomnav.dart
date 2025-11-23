import 'package:flutter/material.dart';
import 'package:tmdbmovies/homepage.dart';
import 'package:tmdbmovies/profilepage.dart';
import 'package:tmdbmovies/watchlist.dart';

import 'appdesign.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _selectedIndex = 0;
  final List<Widget> pages = [
    HomePage(),
    WatchListPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        elevation: 2,iconSize: 20,selectedItemColor: AppDesign().primaryAccent,
        backgroundColor: AppDesign().bgColor,
        unselectedItemColor: AppDesign().textColor,showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),backgroundColor: AppDesign().bgColor,label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list),backgroundColor: AppDesign().bgColor,label: "WatchList"),
          BottomNavigationBarItem(icon: Icon(Icons.person),backgroundColor: AppDesign().bgColor,label: "Profile"),
        ]
    )
    );
  }
}
