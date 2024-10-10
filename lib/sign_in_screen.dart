import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'broadcaster_screen.dart';
import 'viewer_screen.dart';

class SignInScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _signInAnonymously();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BroadcasterScreen()),
            );
          },
          child: Text('Start Broadcasting'),
        ),
      ),
    );
  }
}
