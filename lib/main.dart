import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tmdbmovies/detailpage.dart';
import 'package:tmdbmovies/homepage.dart';
import 'package:tmdbmovies/maintohandlebottomnav.dart';
import 'package:tmdbmovies/profilepage.dart';
import 'package:tmdbmovies/signuppage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: SignUp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TMDB Movies App"),
        backgroundColor: Colors.red.shade500,
        elevation: 5,
      ),
    );
  }
}

//  Tmdb base url :- https://image.tmdb.org/t/p/w500


