import 'package:dexdo/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:dexdo/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository();
}

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<User?> build() {
    final user = ref.read(authRepositoryProvider).currentUser;
    return AsyncValue.data(user);
  }

  Future<UserCredential?> signInAnonymously() async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).signInAnonymously();
    if (result != null) {
      state = AsyncValue.data(result.user);
    } else {
      state = AsyncValue.error('Sign in failed', StackTrace.current);
    }
    return result;
  }

  Future<UserCredential?> linkWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).linkWithGoogle();
    if (result != null) {
      state = AsyncValue.data(result.user);
    } else {
      state = AsyncValue.error('Google link failed', StackTrace.current);
    }
    return result;
  }

  Future<void> updateProfile({String? displayName}) async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).updateProfile(displayName: displayName);
    final user = ref.read(authRepositoryProvider).currentUser;
    state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }
}
