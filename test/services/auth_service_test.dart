import 'package:dexdo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser({this.uid = 'test-uid'});
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
  void initialize() {}
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
  });
}

