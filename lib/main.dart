import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Firebase関係のインポート
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// プラットフォームの確認
final isAndroid =
    defaultTargetPlatform == TargetPlatform.android ? true : false;
final isIOS = defaultTargetPlatform == TargetPlatform.iOS ? true : false;

/// FCMバックグランドメッセージの設定
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  /// Firebaseの初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// FCMのバックグランドメッセージを表示
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// runApp w/ Riverpod
  runApp(const MyApp());
}

/// MaterialAppの設定
class MyApp extends StatelessWidget {
  @override
  void initState() {
    super.initState();

    /// FCMのパーミッション設定
    FirebaseMessagingService().setting();

    /// FCMのトークン表示(テスト用)
    FirebaseMessagingService().fcmGetToken();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // デフォルト表示
            Text('Default'),
            // 太さを指定
            Text('Bold', style: TextStyle(fontWeight: FontWeight.bold)),
            // スタイルを指定
            Text('Italic', style: TextStyle(fontStyle: FontStyle.italic)),
            // サイズを指定
            Text('fontSize = 36', style: TextStyle(fontSize: 36)),
            // 色を指定
            Text('Red', style: TextStyle(color: Colors.red)),
            Container(
              width: double.infinity,
              color: Colors.grey,
              // 表示位置を指定
              child: Text('TextAlign.right', textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}

/// Firebase Cloud Messageの設定
class FirebaseMessagingService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// webとiOS向け設定
  void setting() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void fcmGetToken() async {
    /// モバイル向け
    if (isAndroid || isIOS) {
      final fcmToken = await messaging.getToken();
      print(fcmToken);
    }
    // web向け
    else {
      final fcmToken = await messaging.getToken(
          vapidKey: FirebaseOptionMessaging().webPushKeyPair);
      print('web : $fcmToken');
    }
  }
}
