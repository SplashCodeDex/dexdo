import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  /// Logs in silently. Good for tasks app before they explicitly attach an email.
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Auth Error: $e");
      return null;
    }
  }

  /// Links the anonymous account with Google Credentials
  Future<UserCredential?> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        // Link the anonymous account to Google so we don't lose the local tasks
        debugPrint("Linking anonymous account with Google...");
        return await user.linkWithCredential(credential);
      } else {
        // If they aren't anonymous or aren't logged in, log them in standardly
        debugPrint("Signing in with Google directly...");
        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
         debugPrint("The provider is already linked to a user.");
      } else if (e.code == 'credential-already-in-use') {
         debugPrint("The credential is used by a different account - logging in directly.");
         final oldUid = _auth.currentUser?.uid;
         final cred = await _auth.signInWithCredential(e.credential!);
         final newUid = cred.user?.uid;
         if (oldUid != null && newUid != null && oldUid != newUid) {
             try {
               final firestore = FirebaseFirestore.instance;
               final oldTasks = await firestore.collection('users').doc(oldUid).collection('tasks').get();
               var batch = firestore.batch();
               var count = 0;
               for(var doc in oldTasks.docs) {
                  batch.set(firestore.collection('users').doc(newUid).collection('tasks').doc(doc.id), doc.data(), SetOptions(merge: true));
                  count++;
                  if(count >= 490) { await batch.commit(); batch = firestore.batch(); count = 0;}
               }
               if(count > 0) await batch.commit();
               
               final oldSettings = await firestore.collection('users').doc(oldUid).collection('settings').get();
               var sBatch = firestore.batch();
               for(var doc in oldSettings.docs) {
                  sBatch.set(firestore.collection('users').doc(newUid).collection('settings').doc(doc.id), doc.data(), SetOptions(merge: true));
               }
               await sBatch.commit();
               debugPrint("Merged data to new account.");
             } catch(mergeErr) {
               debugPrint("Merge err: $mergeErr");
             }
         }
         return cred;
      }
      debugPrint("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Generic Auth Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

