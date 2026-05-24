// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dexdo/features/settings/presentation/widgets/dynamic_avatar.dart'
    as _dexdo_features_settings_presentation_widgets_dynamic_avatar;
import 'package:dexdo/features/settings/presentation/widgets/productivity_rings.dart'
    as _dexdo_features_settings_presentation_widgets_productivity_rings;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'features',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'settings',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'presentation',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'widgets',
                children: [
                  _widgetbook.WidgetbookLeafComponent(
                    name: 'DynamicAvatar',
                    useCase: _widgetbook.WidgetbookUseCase(
                      name: 'Default',
                      builder:
                          _dexdo_features_settings_presentation_widgets_dynamic_avatar
                              .buildDynamicAvatarUseCase,
                    ),
                  ),
                  _widgetbook.WidgetbookLeafComponent(
                    name: 'ProductivityRings',
                    useCase: _widgetbook.WidgetbookUseCase(
                      name: 'Default',
                      builder:
                          _dexdo_features_settings_presentation_widgets_productivity_rings
                              .buildProductivityRingsUseCase,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      )
    ],
  )
];
