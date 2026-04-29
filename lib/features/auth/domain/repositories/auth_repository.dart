import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isAnonymous;
  Future<UserCredential?> signInAnonymously();
  Future<UserCredential?> linkWithGoogle();
  Future<void> signOut();
}
