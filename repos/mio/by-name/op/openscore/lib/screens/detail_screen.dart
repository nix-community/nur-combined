import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../models/score.dart';
import '../services/download_store.dart';
import '../services/musescore_api.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.api,
    required this.settings,
    required this.store,
    required this.score,
  });

  final MuseScoreApi api;
  final AppSettings settings;
  final DownloadStore store;
  final ScoreInfo score;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _busy = false;
  String _status = '';

  Future<void> _download(DownloadFormat format) async {
    setState(() {
      _busy = true;
      _status = 'Starting ${format.label}…';
    });
    try {
      final bytes = await widget.api.download(
        widget.score,
        format,
        onProgress: (s) {
          if (mounted) setState(() => _status = s);
        },
      );
      final dir = await widget.settings.resolveDownloadDir();
      final file = File(
        p.join(dir.path, '${widget.score.fileName}.${format.fileExtension}'),
      );
      await file.writeAsBytes(bytes, flush: true);
      await widget.store.add(
        DownloadedItem(
          path: file.path,
          title: widget.score.title,
          format: format,
          scoreId: widget.score.id,
          savedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = 'Saved ${file.path}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${format.label} to ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.score;
    return Scaffold(
      appBar: AppBar(title: Text(score.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (score.thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                score.thumbnailUrl,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 120,
                  child: Center(child: Icon(Icons.music_note, size: 48)),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(score.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('ID ${score.id}'),
          if (score.pageCount > 0) Text('${score.pageCount} pages'),
          const SizedBox(height: 8),
          SelectableText(score.url),
          const SizedBox(height: 24),
          Text('Download', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final format in DownloadFormat.values)
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : () => _download(format),
                  icon: const Icon(Icons.download),
                  label: Text(format.label),
                ),
            ],
          ),
          if (_busy || _status.isNotEmpty) ...[
            const SizedBox(height: 16),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(_status),
          ],
        ],
      ),
    );
  }
}
