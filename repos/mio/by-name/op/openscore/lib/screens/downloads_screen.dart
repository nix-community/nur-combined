import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../models/score.dart';
import '../services/download_store.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key, required this.store});

  final DownloadStore store;

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = widget.store.list();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Downloads',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No downloads'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final exists = File(item.path).existsSync();
                      return ListTile(
                        leading: Icon(switch (item.format) {
                          DownloadFormat.midi => Icons.piano,
                          DownloadFormat.mp3 => Icons.audiotrack,
                          DownloadFormat.pdf => Icons.picture_as_pdf,
                        }),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.format.label} · ${item.path}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        enabled: exists,
                        onTap: exists
                            ? () async {
                                final result = await OpenFilex.open(item.path);
                                if (!context.mounted) return;
                                if (result.type != ResultType.done) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message.isEmpty
                                            ? 'No program registered to open this file'
                                            : result.message,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await widget.store.remove(item.path);
                            _refresh();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
