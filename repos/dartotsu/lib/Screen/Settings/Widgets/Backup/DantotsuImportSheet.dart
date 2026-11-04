import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../Core/Preferences/DantotsuImport.dart';
import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Logger.dart';
import '../../../../Utils/Extensions/ContextExtensions.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../../../../Widgets/Components/CustomBottomDialog.dart';
import 'BackupActionButton.dart';
import 'BackupPanel.dart';
import 'BackupSelection.dart';
import 'PasswordField.dart';

void showDantotsuImport(BuildContext context) =>
    showCustomBottomDialog<void>(context, const _DantotsuImportSheet());

String _label(String id) => switch (id) {
  'anilist' => getString.dantotsuAnilist,
  'mal' => getString.dantotsuMal,
  'discord' => getString.dantotsuDiscord,
  'theme' => getString.dantotsuTheme,
  'repos-anime' => getString.dantotsuReposAnime,
  'repos-manga' => getString.dantotsuReposManga,
  'repos-novel' => getString.dantotsuReposNovel,
  'updates' => getString.dantotsuUpdates,
  'comments' => getString.dantotsuComments,
  'activity' => getString.dantotsuActivity,
  'dns' => getString.dantotsuDns,
  _ => getString.dantotsuPlayer,
};

String _group(DantotsuGroup group) => switch (group) {
  DantotsuGroup.accounts => getString.dantotsuGroupAccounts,
  DantotsuGroup.appearance => getString.dantotsuGroupAppearance,
  DantotsuGroup.extensions => getString.dantotsuGroupExtensions,
  DantotsuGroup.app => getString.dantotsuGroupApp,
  DantotsuGroup.player => getString.dantotsuGroupPlayer,
};

class _DantotsuImportSheet extends StatefulWidget {
  const _DantotsuImportSheet();

  @override
  State<_DantotsuImportSheet> createState() => _DantotsuImportSheetState();
}

class _DantotsuImportSheetState extends State<_DantotsuImportSheet> {
  final _busy = false.live;
  final _path = Live<String?>(null);
  final _items = Live<List<DantotsuItem>?>(null);
  final _selected = <String, bool>{}.liveMap;
  final _failures = <String, String>{}.liveMap;
  final _error = Live<String?>(null);
  final _hidden = true.live;
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  bool get _needsPassword {
    final path = _path.value;
    return path != null && DantotsuBackup.encryptedName(path);
  }

  Future<void> _pick() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: getString.dantotsuPick,
      type: FileType.custom,
      allowedExtensions: ['ani', 'sani'],
    );
    final path = picked?.path;
    if (path == null) return;
    _path.value = path;
    _items.value = null;
    _error.value = null;
    _failures.clear();
    _password.clear();
    if (!_needsPassword) await _read();
  }

  Future<void> _read() async {
    final path = _path.value;
    if (path == null) return;
    _busy.value = true;
    try {
      final backup = await DantotsuBackup.read(path, password: _password.text);
      final items = planDantotsu(backup);
      _items.value = items;
      _selected
        ..clear()
        ..addAll({for (final i in items) i.id: true});
      _error.value = items.isEmpty ? getString.dantotsuNothing : null;
    } catch (e, st) {
      logError('DantotsuImport', e, st, 'read failed');
      _items.value = null;
      _error.value = _needsPassword
          ? getString.backupWrongPassword
          : getString.backupRestoreFailed('$e');
    } finally {
      _busy.value = false;
    }
  }

  Future<void> _apply() async {
    final items = _items.value;
    if (items == null) return;
    final chosen = [
      for (final i in items)
        if (_selected[i.id] == true) i,
    ];
    if (chosen.isEmpty) return;
    _busy.value = true;
    _failures.clear();
    var done = 0;
    for (final item in chosen) {
      final problem = await item.apply();
      if (problem == null) {
        done++;
      } else {
        _failures[item.id] = problem;
      }
    }
    _busy.value = false;
    snackString(getString.dantotsuDone(done, chosen.length));
  }

  @override
  Widget build(BuildContext context) => CustomBottomDialog(
    title: getString.dantotsuImport,
    viewList: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Watch(() => _body(context)),
      ),
    ],
  );

  Widget _body(BuildContext context) {
    final scheme = context.colorScheme;
    final items = _items.value;
    final groups = <DantotsuGroup, List<DantotsuItem>>{};
    for (final i in items ?? const <DantotsuItem>[]) {
      (groups[i.group] ??= []).add(i);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getString.dantotsuImportDesc,
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (_error.value != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _error.value!,
              style: context.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
        if (_path.value != null && _needsPassword && items == null) ...[
          PasswordField(
            controller: _password,
            hidden: _hidden,
            onSubmitted: _read,
          ),
          const SizedBox(height: 12),
          BackupActionButton(
            icon: Icons.lock_open_rounded,
            label: getString.backupUnlock,
            busy: _busy,
            onPressed: _read,
          ),
          const SizedBox(height: 12),
        ],
        if (items != null && items.isNotEmpty) ...[
          SelectAllButton<String>(selection: _selected),
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Text(
                _group(entry.key),
                style: context.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            BackupPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [for (final item in entry.value) _row(context, item)],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            getString.dantotsuWarning,
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          BackupActionButton(
            icon: Icons.download_done_rounded,
            label: getString.dantotsuApply,
            busy: _busy,
            onPressed: _apply,
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.folder_open_rounded),
            label: Text(
              _path.value == null
                  ? getString.dantotsuPick
                  : getString.backupChooseAnother,
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, DantotsuItem item) {
    final scheme = context.colorScheme;
    final failure = _failures[item.id];
    return CheckboxListTile(
      value: _selected[item.id] ?? false,
      onChanged: (v) => _selected[item.id] = v ?? false,
      title: Text(_label(item.id)),
      subtitle: failure != null
          ? Text(failure, style: TextStyle(color: scheme.error))
          : item.detail.isEmpty
          ? null
          : Text(item.detail),
    );
  }
}
