import 'package:flutter/material.dart';

import '../../../../Core/Preferences/PrefManager.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

Set<PrefLocation> chosenLocations(Map<PrefLocation, bool> map) => {
  for (final e in map.entries)
    if (e.value) e.key,
};

class SelectAllButton<K> extends StatelessWidget {
  final Map<K, bool> selection;

  const SelectAllButton({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    final all = selection.isNotEmpty && selection.values.every((v) => v);
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () {
          for (final k in selection.keys.toList()) {
            selection[k] = !all;
          }
        },
        child: Text(all ? getString.backupClearAll : getString.backupSelectAll),
      ),
    );
  }
}
