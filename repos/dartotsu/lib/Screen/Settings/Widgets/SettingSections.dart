import 'package:flutter/material.dart';

import '../../../Model/Setting.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../SubSettingsScreen.dart';

class SettingSection {
  final String title;
  final IconData icon;
  final String? description;
  final List<String> includes;

  const SettingSection(
    this.title,
    this.icon, {
    this.description,
    this.includes = const [],
  });
}

List<Setting> sectionRows(
  List<Setting> rows,
  String title, {
  List<String> includes = const [],
}) {
  final out = <Setting>[];
  var inside = false;
  var nested = false;
  for (final row in rows) {
    if (row.type == SettingType.header) {
      if (row.name == title) {
        inside = true;
        nested = false;
      } else if (inside && includes.contains(row.name)) {
        nested = true;
        out.add(row);
      } else if (inside) {
        break;
      }
      continue;
    }
    if (inside || nested) out.add(row);
  }
  return out;
}

List<Setting> foldSections(
  BuildContext context,
  List<Setting> Function(BuildContext context) build,
  List<SettingSection> sections,
) {
  final byTitle = {for (final s in sections) s.title: s};
  final nested = {for (final s in sections) ...s.includes};
  final rows = build(context);
  final out = <Setting>[];
  var skipping = false;
  for (final row in rows) {
    if (row.type == SettingType.header) {
      if (nested.contains(row.name)) {
        skipping = true;
        continue;
      }
      final section = byTitle[row.name];
      skipping = section != null;
      if (section != null) {
        out.add(
          Setting.normal(
            name: section.title,
            description: section.description,
            icon: section.icon,
            isActivity: true,
            onClick: () => navigateToPage(
              context,
              SubSettingsScreen(
                title: section.title,
                settings: (c) => sectionRows(
                  build(c),
                  section.title,
                  includes: section.includes,
                ),
              ),
            ),
          ),
        );
        continue;
      }
    }
    if (!skipping) out.add(row);
  }
  return out;
}
