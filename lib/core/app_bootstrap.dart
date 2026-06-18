import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/home/presentation/widgets/animated_splash_screen.dart';
import 'package:dexdo/firebase_options.dart';
import 'package:dexdo/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    AppLogger.e('Flutter Error', errorDetails.exception, errorDetails.stack);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    AppLogger.e('Platform Error', error, stack);
    return true;
  };

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  
  AppLogger.i('Firebase and Crashlytics successfully initialized in background');
});

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  bool _animationFinished = false;

  void _onAnimationComplete() {
    if (mounted) {
      setState(() {
        _animationFinished = true;
      });
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    final startupState = ref.read(appStartupProvider);
    if (startupState.hasValue && _animationFinished) {
      // Use microtask to ensure we don't navigate during a build phase
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (_, _, _) => const HomeScreen(),
              transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch to rebuild when Future completes
    ref.listen<AsyncValue<void>>(
      appStartupProvider,
      (_, next) {
        if (next.hasValue && _animationFinished) {
          _checkAndNavigate();
        }
      },
    );

    final startupState = ref.watch(appStartupProvider);

    if (startupState.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                'Initialization Error\n${startupState.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(appStartupProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSplashScreen(onComplete: _onAnimationComplete);
  }
}
