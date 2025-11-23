import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:tmdbmovies/maintohandlebottomnav.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:tmdbmovies/signuppage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? userLoginState;

  @override
  void initState() {
    super.initState();
    getLogin();
  }

  Future<void> getLogin() async{
    var login = await SharedPreferenceHelper().getLoginState();
    userLoginState = login;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Image.asset("assets/usedIcons/splash.png"),
        nextScreen: (userLoginState==null || userLoginState == false) ? SignUp() : MainContainerScreen(),
        backgroundColor: Colors.black,
    splashTransition: SplashTransition.slideTransition,
    curve: Curves.easeInOut,
    splashIconSize: 140,
    duration: 2,
    animationDuration: Duration(seconds: 3));
  }
}
