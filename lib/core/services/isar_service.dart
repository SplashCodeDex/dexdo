import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../features/tasks/data/models/task_model.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [TaskModelSchema, CategoryModelSchema],
      directory: dir.path,
    );
    return _instance!;
  }
}
