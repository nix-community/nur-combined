import 'dart:io';

import 'package:dartotsu_extension_bridge/Models/Video.dart' as v;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'Engine/PlayRequest.dart';
import 'Engine/PlayerPlaylist.dart';
import 'Engine/PlayerSupport.dart';
import 'Engine/TorrentStream.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/DeepLink.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import 'PlayerScreen.dart';

Future<void> openPlayer(PlayRequest request, {BuildContext? context}) async {
  final target = context ?? appContext;
  if (target == null || request.items.isEmpty) return;
  if (!PlayerSupport.available) {
    snackString(getString.playerUnsupported, clipboard: PlayerSupport.failure);
    return;
  }
  await navigateToPage(target, PlayerScreen(request: request));
}

void installPlayerLinks() => DeepLink.playFiles = (paths) => playPaths(paths);

Future<void> playPaths(List<String> paths) async {
  final files = <String>[];
  for (final path in paths) {
    if (FileSystemEntity.isDirectorySync(path)) {
      files.addAll(videosIn(path));
    } else if (isVideoPath(path)) {
      files.add(path);
    } else if (path.toLowerCase().endsWith('.torrent') ||
        path.toLowerCase().startsWith('magnet:')) {
      return playTorrent(path);
    }
  }
  if (files.isEmpty) return snackString(getString.playerNoVideos);
  await openPlayer(
    PlayRequest(items: [for (final (i, f) in files.indexed) localItem(f, i)]),
  );
}

Future<void> pickAndPlayFiles() async {
  final picked = await FilePicker.pickFiles(type: FileType.video);
  final paths = [
    for (final f in picked)
      if (f.path != null) f.path!,
  ];
  if (paths.isNotEmpty) await playPaths(paths);
}

Future<void> pickAndPlayFolder() async {
  final dir = await FilePicker.getDirectoryPath();
  if (dir == null) return;
  await playPaths([dir]);
}

Future<void> playTorrent(String source, {String? title}) async {
  if (!torrentReady) return snackString(getString.playerTorrentMissing);
  final name = title != null && title.trim().isNotEmpty
      ? title.trim()
      : source.startsWith('magnet:')
      ? (Uri.tryParse(source)?.queryParameters['dn'] ?? 'Torrent')
      : p.basenameWithoutExtension(source);
  await openPlayer(
    PlayRequest(
      items: [
        PlayItem(
          key: source,
          title: name,
          subtitle: getString.playerTorrent,
          fixed: [v.Video(name, source, 'Torrent')],
        ),
      ],
    ),
  );
}

Future<void> pickAndPlayTorrentFile() async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['torrent'],
  );
  final path = picked?.path;
  if (path != null) await playTorrent(path);
}

void askNetworkStream(BuildContext context) {
  final url = TextEditingController();
  final host = TextEditingController();
  AlertDialogBuilder(context)
      .setTitle(getString.playerNetworkStream)
      .setCustomView(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: getString.playerStreamUrl,
                hintText: 'https://example.com/video.m3u8',
                prefixIcon: const Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: host,
              decoration: InputDecoration(
                labelText: getString.playerStreamReferer,
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.public_rounded),
              ),
            ),
          ],
        ),
      )
      .setNegativeButton(getString.cancel, null)
      .setPositiveButton(getString.ok, () {
        final link = url.text.trim();
        if (link.isEmpty) return;
        if (isTorrentSource(link)) {
          playTorrent(link);
          return;
        }
        openPlayer(
          PlayRequest(
            items: [networkItem(link, headers: refererHeaders(host.text))],
          ),
        );
      })
      .show();
}

void askTorrent(BuildContext context) {
  final link = TextEditingController();
  AlertDialogBuilder(context)
      .setTitle(getString.playerTorrent)
      .setCustomView(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: link,
              decoration: InputDecoration(
                labelText: getString.playerMagnetLink,
                hintText: 'magnet:?xt=urn:btih:…',
                prefixIcon: const Icon(Icons.hub_rounded),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickAndPlayTorrentFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(getString.playerPickTorrent),
            ),
          ],
        ),
      )
      .setNegativeButton(getString.cancel, null)
      .setPositiveButton(getString.ok, () {
        final value = link.text.trim();
        if (value.isNotEmpty) playTorrent(value);
      })
      .show();
}
