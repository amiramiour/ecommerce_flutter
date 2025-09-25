import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> registerWithEmail(String email, String password);
  Future<void> signOut();
  AppUser? currentUser();
}
