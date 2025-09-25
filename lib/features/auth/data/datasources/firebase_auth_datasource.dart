import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthDataSource {
  final fb.FirebaseAuth auth;
  FirebaseAuthDataSource(this.auth);

  Stream<fb.User?> authState() => auth.authStateChanges();

  Future<fb.User> signIn(String email, String password) async {
    final cred =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  Future<fb.User> register(String email, String password) async {
    final cred = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return cred.user!;
  }

  Future<void> signOut() => auth.signOut();

  fb.User? currentUser() => auth.currentUser;

  Future<fb.User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: popup OAuth natif Firebase
      final provider = fb.GoogleAuthProvider();
      final cred = await auth.signInWithPopup(provider);
      return cred.user;
    } else {
      // Android/iOS: GoogleSignIn -> credential Firebase
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw fb.FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Utilisateur a annulé Google Sign-In',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await auth.signInWithCredential(credential);
      return cred.user;
    }
  }

  Future<void> signOutAll() async {
    if (!kIsWeb) {
      // nettoie aussi la session Google locale
      await GoogleSignIn().signOut();
    }
    await auth.signOut();
  }
}
