import 'dart:async';

import 'package:dexdo/features/auth/data/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FakeUser extends Fake implements User {
  FakeUser({this.uid = 'test-uid'});
  @override
  final String uid;
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  User? _currentUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  void simulateAuthState(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }
}

class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  @override
  Future<void> initialize({
    String? clientId,
    String? hostedDomain,
    String? nonce,
    String? serverClientId,
  }) async {}
}

void main() {
  group('AuthService Unit Tests', () {
    late AuthService authService;
    late FakeFirebaseAuth fakeAuth;
    late FakeGoogleSignIn fakeGoogle;

    setUp(() {
      fakeAuth = FakeFirebaseAuth();
      fakeGoogle = FakeGoogleSignIn();
      authService = AuthService(auth: fakeAuth, googleSignIn: fakeGoogle);
    });

    test('isAnonymous defaults to true when currentUser is null', () {
      fakeAuth.simulateAuthState(null);
      expect(authService.isAnonymous, true);
    });

    test('isAnonymous is false when a non-anonymous user is signed in', () {
      // FakeUser.isAnonymous defaults to false (not overridden = Fake returns false)
      fakeAuth.simulateAuthState(FakeUser(uid: 'real-uid'));
      expect(authService.isAnonymous, false);
    });
  });
}
