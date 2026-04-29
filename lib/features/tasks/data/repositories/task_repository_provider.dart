import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/task_repository.dart';
import 'hybrid_task_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  // We need to pass something that acts like old AuthService if HybridTaskRepository still expects it
  // Or we refactor HybridTaskRepository to use Riverpod ref.
  return HybridTaskRepository(ref);
});
