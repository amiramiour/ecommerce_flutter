import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirebaseAuthDataSource {
  final fb.FirebaseAuth auth;
  FirebaseAuthDataSource(this.auth);

  Stream<fb.User?> authState() => auth.authStateChanges();

  Future<fb.User> signIn(String email, String password) async {
    final cred = await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  Future<fb.User> register(String email, String password) async {
    final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  Future<void> signOut() => auth.signOut();

  fb.User? currentUser() => auth.currentUser;
}
