import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'

void main() async {
  requestNotificationPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  // Firebaseを初期化
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // 通知の設定
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // 通知の内容を表示
        print('Received message: ${message.notification!.title}');
        print('Message body: ${message.notification!.body}');
        _showNotificationDialog(message.notification!.title, message.notification!.body);
      }
    });

    // FCMトークンを取得
    messaging.getToken().then((String? token) {
      print("FCM Token: $token");
    });
  }

  // 通知ダイアログを表示
  void _showNotificationDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? 'No Title'),
          content: Text(body ?? 'No Content'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Web FCM')),
      body: Center(child: Text('Firebase Cloud Messaging for Web')),
    );
  }
}

void requestNotificationPermission() async {
  // Web通知の許可をリクエスト
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('Notification permission: ${settings.authorizationStatus}');
}
