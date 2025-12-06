import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tmdbmovies/notification_services.dart';
import 'package:tmdbmovies/splashscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandling);
  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandling(RemoteMessage message) async{
  await Firebase.initializeApp();
  print(message.notification!.title);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationServices services = NotificationServices();

  @override
  void initState() {
    super.initState();
    services.firebaseInit(context);
    services.backgroundMessageHandle(context);
    services.getDeviceToken().then((value) {
      print("The device token is $value");
    });
  }

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


