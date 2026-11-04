import '../../Logger.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Model/Setting.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import '../../Widgets/Components/ScreenState.dart';

class SourcePreferenceState extends ScreenState {
  final Source source;

  SourcePreferenceState(this.source);

  final prefs = Live<List<SourcePreference>?>(null);

  @override
  void onInit() => load();

  Future<void> load() async {
    try {
      prefs.value = await source.methods.getPreference();
    } catch (e, st) {
      logError('SourcePreferenceState', e, st);
      prefs.value = const [];
    }
  }

  Future<void> write(SourcePreference pref, Object? value) async {
    await source.methods.setPreference(pref, value);
    await load();
  }

  Setting setting(BuildContext context, SourcePreference pref) {
    switch (pref.type) {
      case 'checkbox':
        final p = pref.checkBoxPreference!;
        return Setting.switchType(
          name: p.title ?? pref.key ?? '',
          description: p.summary,
          isChecked: p.value ?? false,
          onSwitchChange: (v) => write(pref, v),
        );
      case 'switch':
        final p = pref.switchPreferenceCompat!;
        return Setting.switchType(
          name: p.title ?? pref.key ?? '',
          description: p.summary,
          isChecked: p.value ?? false,
          onSwitchChange: (v) => write(pref, v),
        );
      case 'list':
        return _list(context, pref);
      case 'multi_select':
        return _multi(context, pref);
      case 'text':
        return _text(context, pref);
      default:
        return Setting.normal(
          name: pref.key ?? getString.unknownPreference,
          description: getString.unsupportedPreferenceType(
            pref.type.toString(),
          ),
        );
    }
  }

  Setting _list(BuildContext context, SourcePreference pref) {
    final p = pref.listPreference!;
    final entries = p.entries ?? const <String>[];
    final values = p.entryValues ?? const <String>[];
    final selected = p.value != null && values.contains(p.value)
        ? values.indexOf(p.value!)
        : 0;
    final current = selected < entries.length ? entries[selected] : null;
    final summary = p.summary ?? '';
    return Setting.normal(
      name: p.title ?? pref.key ?? '',
      description: current == null || summary == current
          ? summary
          : '$summary ($current)',
      isActivity: true,
      onClick: () => AlertDialogBuilder(context)
        ..setTitle(p.title ?? '')
        ..singleChoiceItems(entries, selected, (i) => write(pref, values[i]))
        ..show(),
    );
  }

  Setting _multi(BuildContext context, SourcePreference pref) {
    final p = pref.multiSelectListPreference!;
    final entries = p.entries ?? const <String>[];
    final values = p.entryValues ?? const <String>[];
    final chosen = [
      for (var i = 0; i < entries.length && i < values.length; i++)
        if (p.values?.contains(values[i]) ?? false) entries[i],
    ].join(', ');
    return Setting.normal(
      name: p.title ?? pref.key ?? '',
      description: p.summary?.isNotEmpty == true ? p.summary : chosen,
      isActivity: true,
      onClick: () {
        var checked = [for (final v in values) p.values?.contains(v) ?? false];
        AlertDialogBuilder(context)
          ..setTitle(p.title ?? '')
          ..multiChoiceItems(entries, checked, (next) => checked = next)
          ..setNegativeButton(getString.cancel, null)
          ..setPositiveButton(
            getString.ok,
            () => write(pref, [
              for (var i = 0; i < values.length; i++)
                if (checked[i]) values[i],
            ]),
          )
          ..show();
      },
    );
  }

  Setting _text(BuildContext context, SourcePreference pref) {
    final p = pref.editTextPreference!;
    final secret = pref.key?.toLowerCase().contains('password') ?? false;
    final text = p.value ?? p.text ?? '';
    return Setting.normal(
      name: p.title ?? pref.key ?? '',
      description: secret ? '•' * text.length : (p.summary ?? text),
      isActivity: true,
      onClick: () {
        var value = text;
        AlertDialogBuilder(context)
          ..setTitle(p.dialogTitle ?? p.title ?? '')
          ..setMessage(p.dialogMessage ?? '')
          ..setCustomView(
            TextFormField(
              initialValue: value,
              obscureText: secret,
              keyboardType: secret
                  ? TextInputType.visiblePassword
                  : TextInputType.multiline,
              minLines: 1,
              maxLines: secret ? 1 : 8,
              onChanged: (v) => value = v,
            ),
          )
          ..setNegativeButton(getString.cancel, null)
          ..setPositiveButton(getString.ok, () => write(pref, value))
          ..show();
      },
    );
  }
}
