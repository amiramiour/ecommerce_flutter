import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_flutter/features/auth/domain/entities/app_user.dart';
import 'package:ecommerce_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_flutter/features/auth/presentation/viewmodels/auth_controller.dart';

/// Fake implémentation de AuthRepository pour isoler AuthController
class FakeAuthRepository implements AuthRepository {
  AppUser? _user;

  FakeAuthRepository([this._user]);

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
  }

  @override
  AppUser? currentUser() => _user;

  @override
  Future<AppUser> registerWithEmail(String email, String password) async {
    _user = AppUser(uid: 'reg123', email: email);
    return _user!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    _user = AppUser(uid: 'login123', email: email);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    _user = AppUser(uid: 'google123', email: 'google@test.com');
    return _user;
  }
}

void main() {
  test('signIn met à jour le state avec un AppUser', () async {
    final repo = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);

    await controller.signIn('test@test.com', 'pwd');

    final state = container.read(authControllerProvider);
    expect(state.value, isA<AppUser>());
    expect(state.value!.uid, 'login123');
  });

  test('signOut remet le state à null', () async {
    final repo = FakeAuthRepository(AppUser(uid: 'u1', email: 'a@a.com'));
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);

    await controller.signOut();

    final state = container.read(authControllerProvider);
    expect(state.value, isNull);
  });
}
