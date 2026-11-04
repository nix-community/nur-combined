import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../Engine/MpvFiles.dart';
import '../Engine/PlayerSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/AppSheet.dart';
import '../../../Widgets/Components/SheetTile.dart';

class MpvConfSheet extends StatefulWidget {
  const MpvConfSheet({super.key});

  @override
  State<MpvConfSheet> createState() => _MpvConfSheetState();
}

class _MpvConfSheetState extends State<MpvConfSheet> {
  final _controller = TextEditingController();
  final _path = ''.live;
  final _ready = false.live;

  @override
  void initState() {
    super.initState();
    () async {
      final file = await MpvFiles.confFile();
      _controller.text = await file.readAsString();
      _path.value = file.path;
      _ready.value = true;
    }();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await MpvFiles.writeConf(_controller.text);
    snackString(getString.playerMpvConfSaved);
    if (mounted) popPage(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppSheet(
      title: getString.playerMpvConf,
      heightFactor: 0.85,
      trailing: Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: FilledButton(onPressed: _save, child: Text(getString.save)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Watch(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getString.playerMpvConfDesc,
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (_path.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: SelectableText(
                    _path.value,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: _ready.value,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'hwdec=auto\nscale=ewa_lanczossharp\n# comment',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MpvScriptsSheet extends StatefulWidget {
  final PlayerSettings Function() settings;
  final void Function(List<String> disabled) onDisabled;

  const MpvScriptsSheet({
    super.key,
    required this.settings,
    required this.onDisabled,
  });

  @override
  State<MpvScriptsSheet> createState() => _MpvScriptsSheetState();
}

class _MpvScriptsSheetState extends State<MpvScriptsSheet> {
  final _scripts = <String>[].liveList;
  final _disabled = <String>[].liveList;
  final _path = ''.live;
  Disposer? _sub;

  @override
  void initState() {
    super.initState();
    _disabled.value = widget.settings().disabledScripts;
    _sub = onChange(MpvFiles.scriptsVersion, (_) => _refresh());
    _refresh();
  }

  @override
  void dispose() {
    _sub?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final list = await MpvFiles.scripts();
    final dir = await MpvFiles.scriptsDir();
    if (!mounted) return;
    _scripts.value = list;
    _path.value = dir.path;
  }

  Future<void> _add() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    final path = picked?.path;
    if (path == null) return;
    if (!scriptExtensions.any((e) => path.toLowerCase().endsWith(e))) {
      snackString(getString.playerScriptsBadFile);
      return;
    }
    await MpvFiles.importScript(path);
  }

  void _toggle(String name) {
    final next = [..._disabled];
    next.contains(name) ? next.remove(name) : next.add(name);
    _disabled.value = next;
    widget.onDisabled(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppSheet(
      title: getString.playerScripts,
      heightFactor: 0.7,
      trailing: Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: FilledButton.tonalIcon(
          onPressed: _add,
          icon: const Icon(Icons.add_rounded),
          label: Text(getString.playerScriptsAdd),
        ),
      ),
      child: Watch(() {
        final scripts = _scripts.toList();
        final disabled = _disabled.toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              getString.playerScriptsDesc,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (_path.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: SelectableText(
                  _path.value,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
            if (scripts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(getString.playerScriptsNone)),
              ),
            for (final (i, name) in scripts.indexed)
              SheetTile(
                tinted: true,
                radius: BorderRadius.vertical(
                  top: Radius.circular(i == 0 ? 20 : 6),
                  bottom: Radius.circular(i == scripts.length - 1 ? 20 : 6),
                ),
                leading: const Icon(Icons.code_rounded),
                title: Text(name),
                selected: !disabled.contains(name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => MpvFiles.deleteScript(name),
                    ),
                    Switch(
                      value: !disabled.contains(name),
                      onChanged: (_) => _toggle(name),
                    ),
                  ],
                ),
                onTap: () => _toggle(name),
              ),
          ],
        );
      }),
    );
  }
}
