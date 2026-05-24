import 'package:dexdo/features/tasks/data/models/task_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance != null) return _instance!;

    final String directory;
    if (kIsWeb) {
      directory = Isar.sqlitePath;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      directory = dir.path;
    }

    _instance = Isar.open(
      schemas: [TaskModelSchema, CategoryModelSchema],
      directory: directory,
    );
    return _instance!;
  }
}
