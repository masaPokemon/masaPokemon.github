import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // サインイン（EmailとPassword）
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }

  // 新規ユーザー作成（EmailとPassword）
  Future<User?> createUserWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign-up error: $e");
      return null;
    }
  }

  // サインアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 現在サインイン中のユーザー情報を取得
  User? get currentUser => _auth.currentUser;

  // サインイン状態の変化を監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
