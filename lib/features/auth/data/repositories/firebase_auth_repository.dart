import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _googleSignIn.initialize();
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  @override
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Auth Error: $e');
      return null;
    }
  }

  @override
  Future<UserCredential?> linkWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();

        final user = _auth.currentUser;
        if (user != null && user.isAnonymous) {
          debugPrint('Linking anonymous account with Google (Web)...');
          return await user.linkWithPopup(googleProvider);
        } else {
          debugPrint('Signing in with Google directly (Web)...');
          return await _auth.signInWithPopup(googleProvider);
        }
      } else {
        final googleUser = await _googleSignIn.authenticate();

        const scopes = ['email', 'profile', 'openid'];

        final currentAuth = await googleUser.authorizationClient.authorizationForScopes(scopes);

        String? accessToken;
        if (currentAuth == null) {
          final authResult = await googleUser.authorizationClient.authorizeScopes(scopes);
          accessToken = authResult.accessToken;
        } else {
          accessToken = currentAuth.accessToken;
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: googleAuth.idToken,
        );

        final user = _auth.currentUser;
        if (user != null && user.isAnonymous) {
          debugPrint('Linking anonymous account with Google...');
          return await user.linkWithCredential(credential);
        } else {
          debugPrint('Signing in with Google directly...');
          return await _auth.signInWithCredential(credential);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        debugPrint('The provider is already linked to a user.');
      } else if (e.code == 'credential-already-in-use') {
        debugPrint('The credential is used by a different account - logging in directly.');
        final oldUid = _auth.currentUser?.uid;
        final cred = await _auth.signInWithCredential(e.credential!);
        final newUid = cred.user?.uid;
        if (oldUid != null && newUid != null && oldUid != newUid) {
          try {
            final oldTasks = await _firestore.collection('users').doc(oldUid).collection('tasks').get();
            var batch = _firestore.batch();
            var count = 0;
            for (final doc in oldTasks.docs) {
              batch.set(_firestore.collection('users').doc(newUid).collection('tasks').doc(doc.id), doc.data(), SetOptions(merge: true));
              count++;
              if (count >= 490) {
                await batch.commit();
                batch = _firestore.batch();
                count = 0;
              }
            }
            if (count > 0) await batch.commit();

            final oldSettings = await _firestore.collection('users').doc(oldUid).collection('settings').get();
            final sBatch = _firestore.batch();
            for (final doc in oldSettings.docs) {
              sBatch.set(_firestore.collection('users').doc(newUid).collection('settings').doc(doc.id), doc.data(), SetOptions(merge: true));
            }
            await sBatch.commit();
            debugPrint('Merged data to new account.');
          } catch (mergeErr) {
            debugPrint('Merge err: $mergeErr');
          }
        }
        return cred;
      }
      debugPrint('Firebase Auth Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Generic Auth Error: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
