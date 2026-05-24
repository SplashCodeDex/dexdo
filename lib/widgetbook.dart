import 'package:dexdo/core/theme/app_theme.dart';
import 'package:dexdo/l10n/app_localizations.dart';
import 'package:dexdo/widgetbook.directories.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  runApp(
    const ProviderScope(
      child: WidgetbookApp(),
    ),
  );
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.lightTheme,
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: AppTheme.darkTheme,
            ),
          ],
        ),
        LocalizationAddon(
          locales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
        ViewportAddon(
          [
            ...IosViewports.all,
            ...AndroidViewports.all,
          ],
        ),
      ],
    );
  }
}
