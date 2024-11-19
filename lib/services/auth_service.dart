import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google認証
  Future<User?> signInWithGoogle() async {
    try {
      // Google認証の処理（省略）
      // 省略部分はGoogle APIを利用して行います
      return _auth.currentUser;
    } catch (e) {
      print("Google SignIn failed: $e");
      return null;
    }
  }

  // メール・パスワード認証
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Email/Password SignIn failed: $e");
      return null;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 現在のユーザー取得
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
