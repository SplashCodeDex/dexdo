import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/task_repository.dart';
import 'hybrid_task_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final repo = HybridTaskRepository(ref);
  
  // Listen for auth state changes to trigger migration when user logs in
  ref.listen(authStateChangesProvider, (previous, next) {
    if (next.value != null && (previous == null || previous.value == null)) {
      repo.migrate();
    }
  });

  return repo;
});
