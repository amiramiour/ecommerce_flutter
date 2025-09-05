import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// FirebaseAuth instance (facile à mocker en tests)
final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

/// Repo concrete
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final ds = FirebaseAuthDataSource(ref.read(firebaseAuthProvider));
  return AuthRepositoryImpl(ds);
});

/// Stream d’état d’auth
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Contrôleur MVVM
class AuthController extends AsyncNotifier<AppUser?> {
  late final AuthRepository _repo;

  @override
  Future<AppUser?> build() async {
    _repo = ref.read(authRepositoryProvider);
    return _repo.currentUser();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _repo.signInWithEmail(email, password));
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _repo.registerWithEmail(email, password));
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(() => AuthController());

/// Mapping lisible des erreurs Firebase
String mapFirebaseAuthError(Object err) {
  if (err is fb.FirebaseAuthException) {
    switch (err.code) {
      case 'invalid-email':
        return "Email invalide.";
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "Identifiants incorrects.";
      case 'email-already-in-use':
        return "Cet email est déjà utilisé.";
      case 'weak-password':
        return "Mot de passe trop faible (≥ 6 caractères).";
      case 'too-many-requests':
        return "Trop de tentatives. Réessaie plus tard.";
      case 'network-request-failed':
        return "Problème réseau. Vérifie ta connexion.";
      default:
        return "Erreur: ${err.code}";
    }
  }
  return "Une erreur est survenue.";
}
