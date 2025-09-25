import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  AppUser? _map(fb.User? u) =>
      u == null ? null : AppUser(uid: u.uid, email: u.email);

  @override
  Stream<AppUser?> authStateChanges() => _ds.authState().map(_map);

  @override
  AppUser? currentUser() => _map(_ds.currentUser());

  @override
  Future<AppUser> registerWithEmail(String email, String password) async =>
      _map(await _ds.register(email, password))!;

  @override
  Future<AppUser> signInWithEmail(String email, String password) async =>
      _map(await _ds.signIn(email, password))!;

  @override
  Future<void> signOut() => _ds.signOut();
}
