import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:ecommerce_flutter/features/auth/presentation/viewmodels/auth_controller.dart';

void main() {
  group('mapFirebaseAuthError', () {
    test('invalid-email', () {
      final e = fb.FirebaseAuthException(code: 'invalid-email');
      final msg = mapFirebaseAuthError(e);
      expect(
        msg,
        anyOf(contains('Email invalide'), contains('invalid-email')),
      );
    });

    test('wrong-password maps to Identifiants incorrects (or fallback)', () {
      final e = fb.FirebaseAuthException(code: 'wrong-password');
      final msg = mapFirebaseAuthError(e);
      expect(
        msg,
        anyOf(contains('Identifiants incorrects'), contains('wrong-password')),
      );
    });

    test('email-already-in-use (or fallback)', () {
      final e = fb.FirebaseAuthException(code: 'email-already-in-use');
      final msg = mapFirebaseAuthError(e);
      expect(
        msg,
        anyOf(contains('déjà utilisé'), contains('email-already-in-use')),
      );
    });

    test('unknown code falls back to "Erreur: <code>"', () {
      final e = fb.FirebaseAuthException(code: 'some-unknown-code');
      final msg = mapFirebaseAuthError(e);
      expect(msg, contains('some-unknown-code'));
    });
  });
}
