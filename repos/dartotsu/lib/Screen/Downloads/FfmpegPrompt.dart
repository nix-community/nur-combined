import 'dart:async';

import 'package:flutter/material.dart';

import '../../Core/Downloads/DownloadEngine.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';

enum HlsMode { mp4, folder, cancel }

Future<HlsMode> chooseHlsMode(BuildContext context) async {
  final addon = find<DownloadEngine>().ffmpegAddon();
  if (addon == null || !addon.supported) return HlsMode.folder;
  if (addon.installed.value) return HlsMode.mp4;
  final ask = Completer<HlsMode>();
  unawaited(
    AlertDialogBuilder(context)
        .setTitle(getString.downloadFfmpegTitle)
        .setMessage(getString.downloadFfmpegBody)
        .setPositiveButton(getString.downloadFfmpegInstall, () {
          ask.complete(HlsMode.mp4);
        })
        .setNeutralButton(getString.downloadFfmpegFolder, () {
          ask.complete(HlsMode.folder);
        })
        .setNegativeButton(getString.cancel, () => ask.complete(HlsMode.cancel))
        .setOnDismissListener(() {
          if (!ask.isCompleted) ask.complete(HlsMode.cancel);
        })
        .show<void>(),
  );
  final mode = await ask.future;
  if (mode != HlsMode.mp4) return mode;
  snackString(getString.downloadFfmpegInstalling);
  try {
    await addon.install();
  } catch (e) {
    snackString('$e');
    return HlsMode.cancel;
  }
  return addon.installed.value ? HlsMode.mp4 : HlsMode.cancel;
}
