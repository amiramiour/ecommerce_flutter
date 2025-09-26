import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:ecommerce_flutter/features/auth/data/datasources/firebase_auth_datasource.dart';

/// Fake minimal de User
class FakeUser implements fb.User {
  @override
  final String uid;
  @override
  final String? email;

  FakeUser({required this.uid, this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake FirebaseAuth qui simule quelques méthodes
class FakeFirebaseAuth implements fb.FirebaseAuth {
  fb.User? _user;
  bool signOutCalled = false;

  FakeFirebaseAuth([this._user]);

  @override
  fb.User? get currentUser => _user;

  @override
  Future<fb.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = FakeUser(uid: 'uid123', email: email);
    return _FakeUserCredential(_user!);
  }

  @override
  Future<fb.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = FakeUser(uid: 'uid456', email: email);
    return _FakeUserCredential(_user!);
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _user = null;
  }

  @override
  Stream<fb.User?> authStateChanges() async* {
    yield _user;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake UserCredential
class _FakeUserCredential implements fb.UserCredential {
  @override
  final fb.User? user;

  _FakeUserCredential(this.user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('FirebaseAuthDataSource', () {
    test('signIn renvoie un User après login', () async {
      final auth = FakeFirebaseAuth();
      final ds = FirebaseAuthDataSource(auth);

      final user = await ds.signIn('email@test.com', 'pwd');

      expect(user.uid, 'uid123');
      expect(user.email, 'email@test.com');
    });

    test('register renvoie un User après inscription', () async {
      final auth = FakeFirebaseAuth();
      final ds = FirebaseAuthDataSource(auth);

      final user = await ds.register('new@test.com', 'pwd');

      expect(user.uid, 'uid456');
      expect(user.email, 'new@test.com');
    });

    test('signOut vide le currentUser', () async {
      final auth =
          FakeFirebaseAuth(FakeUser(uid: '999', email: 'old@test.com'));
      final ds = FirebaseAuthDataSource(auth);

      await ds.signOut();

      expect(auth.signOutCalled, true);
      expect(auth.currentUser, null);
    });

    test('currentUser retourne le user courant', () {
      final user = FakeUser(uid: '777', email: 'me@test.com');
      final auth = FakeFirebaseAuth(user);
      final ds = FirebaseAuthDataSource(auth);

      final result = ds.currentUser();

      expect(result, isNotNull);
      expect(result!.uid, '777');
    });
  });
}
