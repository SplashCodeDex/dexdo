import 'dart:async';
import 'package:dexdo/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockitoAuthRepository extends Mock implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: const Stream<User?>.empty(),
        returnValueForMissingStub: const Stream<User?>.empty(),
      );

  @override
  Future<UserCredential?> signInAnonymously() => super.noSuchMethod(
        Invocation.method(#signInAnonymously, []),
        returnValue: Future<UserCredential?>.value(null),
        returnValueForMissingStub: Future<UserCredential?>.value(null),
      );

  @override
  Future<UserCredential?> linkWithGoogle() => super.noSuchMethod(
        Invocation.method(#linkWithGoogle, []),
        returnValue: Future<UserCredential?>.value(null),
        returnValueForMissingStub: Future<UserCredential?>.value(null),
      );

  @override
  Future<void> signOut() => super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      );
}

class MockUser extends Fake implements User {
  MockUser({
    this.uid = 'test-uid',
    this.isAnonymous = false,
    this.displayName = 'Test User',
    this.email = 'test@example.com',
    this.photoURL = 'https://example.com/photo.png',
  });
  
  @override
  final String uid;
  @override
  final bool isAnonymous;
  @override
  final String? displayName;
  @override
  final String? email;
  @override
  final String? photoURL;
}
