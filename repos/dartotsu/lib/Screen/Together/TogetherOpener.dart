import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../Player/Engine/PlayRequest.dart';
import '../Player/Engine/TorrentStream.dart';
import '../Player/PlayerLauncher.dart';
import 'TogetherStream.dart';

Future<String?> openTogetherStream(TogetherStream stream) async {
  final video = stream.video;
  if (isTorrentSource(video.url)) {
    if (!torrentReady) return getString.playerTorrentMissing;
    await playTorrent(video.url, title: stream.name);
    return null;
  }
  await openPlayer(
    PlayRequest(
      items: [
        PlayItem(key: 'dt:${stream.id}', title: stream.name, fixed: [video]),
      ],
    ),
  );
  return null;
}
