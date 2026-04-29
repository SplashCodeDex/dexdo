import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final user = ref.read(authRepositoryProvider).currentUser;
    state = AsyncValue.data(user);
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).signInAnonymously();
    if (result != null) {
      state = AsyncValue.data(result.user);
    } else {
      state = AsyncValue.error('Sign in failed', StackTrace.current);
    }
  }

  Future<void> linkWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).linkWithGoogle();
    if (result != null) {
      state = AsyncValue.data(result.user);
    } else {
      state = AsyncValue.error('Google link failed', StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }
}
