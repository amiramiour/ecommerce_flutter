import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:ecommerce_flutter/features/auth/domain/entities/app_user.dart';
import 'package:ecommerce_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_flutter/features/auth/data/datasources/firebase_auth_datasource.dart';

/// Fake minimal de User
class FakeUser implements fb.User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake minimal de FirebaseAuth pour remplir le champ `auth` du DataSource
class _FakeFirebaseAuth implements fb.FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake du DataSource qui renvoie toujours le même user
class FakeDataSource extends FirebaseAuthDataSource {
  final fb.User? _user;

  FakeDataSource(this._user) : super(_FakeFirebaseAuth());

  @override
  Stream<fb.User?> authState() async* {
    yield _user;
  }

  @override
  fb.User? currentUser() => _user;

  @override
  Future<fb.User> register(String email, String password) async => _user!;

  @override
  Future<fb.User> signIn(String email, String password) async => _user!;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signOutAll() async {}

  @override
  Future<fb.User?> signInWithGoogle() async => _user;
}

void main() {
  group('AuthRepositoryImpl', () {
    test('signInWithEmail mappe fb.User en AppUser', () async {
      final fakeUser = FakeUser(uid: '123', email: 'test@test.com');
      final repo = AuthRepositoryImpl(FakeDataSource(fakeUser));

      final result = await repo.signInWithEmail('test@test.com', 'pwd');

      expect(result, isA<AppUser>());
      expect(result.uid, '123');
      expect(result.email, 'test@test.com');
    });

    test('currentUser retourne null si pas connecté', () {
      final repo = AuthRepositoryImpl(FakeDataSource(null));

      final result = repo.currentUser();

      expect(result, null);
    });

    test('signInWithGoogle retourne un AppUser minimal', () async {
      final fakeUser = FakeUser(
        uid: '456',
        email: 'google@test.com',
        displayName: 'Google User',
        photoURL: 'http://photo.com/pic.png',
      );
      final repo = AuthRepositoryImpl(FakeDataSource(fakeUser));

      final result = await repo.signInWithGoogle();

      expect(result, isNotNull);
      expect(result!.uid, '456');
      expect(result.email, 'google@test.com');
    });
  });
}
