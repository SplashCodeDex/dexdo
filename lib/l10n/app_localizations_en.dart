// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DexDo';

  @override
  String get homeTitle => 'Home';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get markCompleted => 'Mark Completed';

  @override
  String get moveCategory => 'Move to Category';

  @override
  String get clearDone => 'Clear Done';

  @override
  String get selectTaskDetail => 'Select a task to view details';

  @override
  String get noCategory => 'No Category';

  @override
  String get allTasks => 'All Tasks';
}
