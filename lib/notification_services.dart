import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tmdbmovies/homepage.dart';

class NotificationServices{
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    void requestUserAboutNotify() async{
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("Permission granted");
    }else if(settings.authorizationStatus == AuthorizationStatus.denied){
      print("Permission denied");
    }
  }

  void initLocalNotification(BuildContext context,RemoteMessage message){
    var androidInitialization = AndroidInitializationSettings('ic_notification');
    var iosInitialization =  DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitialization,
        iOS: iosInitialization
    );

    _localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          handleMessage(context, message);
        });
  }

  void firebaseInit(BuildContext context) async{
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.title.toString());
      print(message.notification!.body.toString());

      initLocalNotification(context, message);
      showNotification(message);
    });
  }

  void handleMessage(BuildContext context,RemoteMessage message) async{
    if(message.data['type'] == 'msg'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  void backgroundMessageHandle(BuildContext context) async{

    //When app in terminated state
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if(message!=null){
      handleMessage(context, message);
    }

    //When app in background state
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }

  Future<void> showNotification(RemoteMessage message) async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random().nextInt(1000).toString(),
        "CineTrack Notifications",
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        channelDescription: 'Subscribe to CineTrack for Trending Tv shows and Movies',
        priority: Priority.high,
        icon: 'ic_notification',
        ticker: 'New Message');

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );

    Future.delayed(Duration(seconds: 0),() {
      _localNotificationsPlugin.show(0,
          message.notification!.title,
          message.notification!.body,
          notificationDetails);
    });
  }

  Future<String> getDeviceToken() async{
    String? token = await _messaging.getToken();
    return token!;
  }

}