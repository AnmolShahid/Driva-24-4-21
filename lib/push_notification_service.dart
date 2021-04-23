import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/constant.dart';


import 'package:firebase_auth/firebase_auth.dart';
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
new FlutterLocalNotificationsPlugin();

//private variable to check if Notification is already Selected;
bool _isNotificationSelected = false;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {

  print("on background");
  if (message.containsKey('data')) {
    final dynamic data = message['data'];

  }
  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];

  }
}

Future onSelectNotification(String payload) async {
  if (!_isNotificationSelected) {
    _isNotificationSelected = true;
  } else {
    _isNotificationSelected = false;
  }
  return Future<void>.value();
}

Future displayNotification(Map<String, dynamic> message) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'driva_default_channel', 'flutterfcm', 'description',
      icon: 'mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high);

  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  var platformChannelSpecifics = new NotificationDetails(android: androidPlatformChannelSpecifics,iOS:  iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    message['notification']['title'],
    message['notification']['body'],
    platformChannelSpecifics,
    payload: 'item x',
  );
}

class PushNotificationService {
  FirebaseMessaging _firebaseMessaging;

  void setUpFirebase() async {
    _firebaseMessaging = FirebaseMessaging();

    firebaseCloudMessaging_Listeners();
  }

  Future getToken() async {
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
 User user = FirebaseAuth.instance.currentUser;
    String token = await _firebaseMessaging.getToken();
    print('token: $token');
    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/token');
    tokenRef.set(token);
    _firebaseMessaging.subscribeToTopic('alldrivers');
    _firebaseMessaging.subscribeToTopic('allusers');

    return await _firebaseMessaging.getToken();
  }

  Future<void> firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print("Push Messaging token: $token");
    });
    try {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("on message ${message.toString()}");
          displayNotification(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
          displayNotification(message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("MSG ${message.toString()}");
          displayNotification(message);
        },
        onBackgroundMessage: Platform.isIOS ? myBackgroundMessageHandler : myBackgroundMessageHandler,
      );
    } catch (e, s) {
      print(s);
    }
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }
}
