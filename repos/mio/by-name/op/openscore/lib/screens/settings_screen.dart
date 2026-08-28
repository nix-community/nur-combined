import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/download_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final Future<void> Function(AppSettings) onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _proxyController = TextEditingController(
    text: widget.settings.proxyUrl,
  );
  late String _theme = widget.settings.themeMode;
  late String? _folder = widget.settings.downloadFolder;

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    final next = AppSettings(
      downloadFolder: _folder,
      themeMode: _theme,
      proxyUrl: _proxyController.text.trim(),
    );
    await widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Download folder'),
            subtitle: Text(_folder ?? 'App documents / OpenScore'),
            trailing: const Icon(Icons.folder_open),
            onTap: () async {
              final path = await FilePicker.platform.getDirectoryPath(
                dialogTitle: 'Choose download folder',
              );
              if (path == null) return;
              setState(() => _folder = path);
              await _persist();
            },
          ),
          if (_folder != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  setState(() => _folder = null);
                  await _persist();
                },
                child: const Text('Reset to default folder'),
              ),
            ),
          const Divider(),
          const Text('Theme'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'system', label: Text('System')),
              ButtonSegment(value: 'light', label: Text('Light')),
              ButtonSegment(value: 'dark', label: Text('Dark')),
            ],
            selected: {_theme},
            onSelectionChanged: (s) async {
              setState(() => _theme = s.first);
              await _persist();
            },
          ),
          const SizedBox(height: 24),
          Text('Proxy', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Optional URL prefix for MuseScore requests. '
            'Use {url} as a placeholder, or a prefix that receives the '
            'URI-encoded target URL.',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _proxyController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'https://example/proxy?url={url}',
              labelText: 'Proxy URL',
            ),
            onEditingComplete: _persist,
            onSubmitted: (_) => _persist(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _persist,
              child: const Text('Save proxy'),
            ),
          ),
        ],
      ),
    );
  }
}
