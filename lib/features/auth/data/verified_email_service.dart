import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class VerifiedUserInfo {
  VerifiedUserInfo({required this.email, required this.displayName});

  final String email;
  final String displayName;
}

class VerifiedEmailService {
  static const MethodChannel _channel = MethodChannel('com.dexify.dexdo/credentials');

  Future<VerifiedUserInfo?> getVerifiedEmail() async {
    try {
      // 1. Generate secure nonce
      final random = Random.secure();
      final nonceBytes = List<int>.generate(32, (i) => random.nextInt(256));
      final String nonce = base64Url.encode(nonceBytes).replaceAll('=', '');

      // 2. Invoke native Credential Manager
      final String? responseJsonString = await _channel.invokeMethod('getVerifiedEmail', {
        'nonce': nonce,
      });

      if (responseJsonString == null) return null;

      // 3. Call Firebase Cloud Function to verify
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyDigitalCredential');
      
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String? currentUid = currentUser?.isAnonymous == true ? currentUser?.uid : null;

      final HttpsCallableResult result = await callable.call({
        'responseJsonString': responseJsonString,
        'nonce': nonce,
        'linkToUid': currentUid,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final String customToken = data['customToken'] as String;
      final userMap = Map<String, dynamic>.from(data['user'] as Map);

      // 4. Sign in with Custom Token
      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      return VerifiedUserInfo(
        email: userMap['email'] ?? 'Unknown Email',
        displayName: userMap['name'] ?? userMap['email'] ?? 'Unknown Name',
      );
    } catch (e) {
      AppLogger.e('Error getting verified email', e);
      return null;
    }
  }
}
