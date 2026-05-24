import 'package:dexdo/features/tasks/data/repositories/firebase_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseTaskRepository Unit Tests', () {
    // FirebaseTaskRepository uses FirebaseAuth and Firestore internally.
    // Real integration requires a configured Firebase environment.
    // The constructor takes no arguments — it resolves credentials from FirebaseAuth.instance.
    // Full coverage lives in integration tests (test/integration/).
    test('FirebaseTaskRepository can be instantiated', () {
      // This validates the class wires up without throwing at construction time.
      // Actual Firestore calls are only made when a User is authenticated.
      final repo = FirebaseTaskRepository();
      expect(repo, isNotNull);
    });
  });
}
