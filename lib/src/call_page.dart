import 'dart:async';
import 'package:agora_token_service/agora_token_service.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "bf70cd8ee96740ff941f3764c5f880a8";
const appCertificate = 'c70b32b75301494ebc30e105738af82d';
final channel = channelName;
const uid = '';
const role = RtcRole.publisher;

const expirationInSeconds = 3600;
final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
final expireTimestamp = currentTimestamp + expirationInSeconds;

final token = RtcTokenBuilder.build(
  appId: appId,
  appCertificate: appCertificate,
  channelName: channel,
  uid: uid,
  role: role,
  expireTimestamp: expireTimestamp,
);
//const token = "007eJxTYEiUdDUtWPNyserME/xBD3ao1+fUshdp+qmrGzr67rx55IgCQ1KauUFyikVqqqWZuYlBWpqliWGasbmZSbJpmoWFQaLFzMuX0xoCGRmKpz9gYmSAQBCfgyE3sTgxOSOxhIEBAFgAIGI=";

//const channel = "masachat";
void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<int> _remoteUid = [];
  bool _localUserJoined = false;
  late RtcEngine _engine;
  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void initState(){
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    _role = ClientRole.Broadcaster;
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    //create the engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {

            _remoteUid.add(uid);
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            int removeObject = _remoteUid.indexOf(uid);
            print(removeObject);
            _remoteUid.remove(uid);
          });
        },
      ),
    );

    await _engine.joinChannel(token, channel, null, 0);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Agora Video Call'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () async {
              await _engine.leaveChannel();
              Navigator.pop(context);
            }, 
            icon: Icon(Icons.call_end))
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _viewRows(),
          ),
        ],
      ),
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (_role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _remoteUid.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(
        channelId: channelName, uid: uid)));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }
  
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[
            _videoView(views[0])
          ],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      case 5:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 5)),
          ],
        ));
      case 6:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
          ],
        ));
      case 7:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 7)),
          ],
        ));
      case 8:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
          ],
        ));
      case 9:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 9)),
          ],
        ));
      case 10:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
          ],
        ));
      case 11:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 11)),
          ],
        ));
      case 12:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 12)),
          ],
        ));
      case 13:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 12)),
            _expandedVideoRow(views.sublist(12, 13)),
          ],
        ));
      case 14:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 12)),
            _expandedVideoRow(views.sublist(12, 14)),
          ],
        ));
      case 15:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 12)),
            _expandedVideoRow(views.sublist(12, 14)),
            _expandedVideoRow(views.sublist(14, 15)),
          ],
        ));
      case 16:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 12)),
            _expandedVideoRow(views.sublist(12, 14)),
            _expandedVideoRow(views.sublist(14, 16)),
          ],
        ));
      case 17:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 8)),
            _expandedVideoRow(views.sublist(8, 10)),
            _expandedVideoRow(views.sublist(10, 12)),
            _expandedVideoRow(views.sublist(12, 14)),
            _expandedVideoRow(views.sublist(14, 17)),
          ],
        ));
      default:
    }
    return Container();
  }
  
  // Display remote user's video
  Widget _remoteVideo() {
    final views = _getRenderViews();
    if (_remoteUid != null) {
      return Container(
        child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        )
      );
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
