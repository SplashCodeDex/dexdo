import 'package:dexdo/features/auth/domain/repositories/auth_repository.dart';
import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../auth_test_utils.dart';
import 'auth_controller_test.mocks.dart';

@GenerateMocks([UserCredential])
void main() {
  late MockitoAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockitoAuthRepository();
    
    // Default behaviors
    when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
    when(mockAuthRepository.currentUser).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController', () {
    test('initial state is current user from repository', () {
      final user = MockUser(uid: 'initial-uid');
      when(mockAuthRepository.currentUser).thenReturn(user);

      final state = container.read(authControllerProvider);
      expect(state, AsyncValue.data(user));
    });

    test('signInAnonymously sets loading then data on success', () async {
      final user = MockUser(uid: 'anon-uid', isAnonymous: true);
      final userCredential = MockUserCredential();
      when(userCredential.user).thenReturn(user);
      when(mockAuthRepository.signInAnonymously()).thenAnswer((_) async => userCredential);

      final controller = container.read(authControllerProvider.notifier);
      
      final future = controller.signInAnonymously();
      
      // Verify loading state
      expect(container.read(authControllerProvider), const AsyncValue<User?>.loading());
      
      final result = await future;
      
      expect(result, userCredential);
      expect(container.read(authControllerProvider), AsyncValue.data(user));
      verify(mockAuthRepository.signInAnonymously()).called(1);
    });

    test('signInAnonymously sets error on failure', () async {
      when(mockAuthRepository.signInAnonymously()).thenAnswer((_) async => null);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signInAnonymously();
      
      expect(container.read(authControllerProvider).hasError, true);
      expect(container.read(authControllerProvider).error, 'Sign in failed');
    });

    test('linkWithGoogle sets loading then data on success', () async {
      final user = MockUser(uid: 'google-uid', isAnonymous: false);
      final userCredential = MockUserCredential();
      when(userCredential.user).thenReturn(user);
      when(mockAuthRepository.linkWithGoogle()).thenAnswer((_) async => userCredential);

      final controller = container.read(authControllerProvider.notifier);
      
      final future = controller.linkWithGoogle();
      expect(container.read(authControllerProvider), const AsyncValue<User?>.loading());
      
      await future;
      
      expect(container.read(authControllerProvider), AsyncValue.data(user));
      verify(mockAuthRepository.linkWithGoogle()).called(1);
    });

    test('signOut sets loading then null data', () async {
      when(mockAuthRepository.signOut()).thenAnswer((_) async => {});

      final controller = container.read(authControllerProvider.notifier);
      
      final future = controller.signOut();
      expect(container.read(authControllerProvider), const AsyncValue<User?>.loading());
      
      await future;
      
      expect(container.read(authControllerProvider), const AsyncValue.data(null));
      verify(mockAuthRepository.signOut()).called(1);
    });
  });
}
