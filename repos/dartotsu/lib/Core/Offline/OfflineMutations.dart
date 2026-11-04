import '../../Utils/Functions/SnackBar.dart';
import '../Services/Api/Progress.dart';
import '../Services/MediaService.dart';
import '../Services/Model/Media.dart';
import '../State/State.dart';
import '../ThemeManager/LanguageSwitcher.dart';
import 'NetStatus.dart';
import 'OfflineMode.dart';
import 'PendingWrites.dart';

class OfflineMutations extends Mutations {
  final MediaService service;
  final Mutations inner;

  static DateTime? _lastNotice;
  static void Function(MediaService service, Media media)? onProgressSaved;

  OfflineMutations(this.service, this.inner);

  Future<bool> _isOffline() async {
    if (find<OfflineMode>().isOffline.value) return true;
    final net = find<NetStatus>();
    if (net.online.value) return false;
    return !await net.check();
  }

  @override
  Future<void> editList(Media media, {List<String>? customList}) async {
    if (await _isOffline()) {
      find<PendingWrites>().record(
        service,
        media,
        PendingKind.edit,
        customList: customList,
      );
      return snackString(getString.offlineSaved);
    }
    await inner.editList(media, customList: customList);
  }

  @override
  Future<void> saveEntry(Media media, {bool? exists}) =>
      inner.saveEntry(media, exists: exists);

  @override
  bool canFavourite(Media media) => inner.canFavourite(media);

  @override
  Future<bool> isFavourite(Media media) async {
    if (await _isOffline()) return media.isFav;
    return inner.isFavourite(media);
  }

  @override
  Future<bool?> toggleFavourite(Media media) async {
    if (await _isOffline()) {
      snackString(getString.offlineModeOn);
      return null;
    }
    return inner.toggleFavourite(media);
  }

  @override
  Future<void> deleteFromList(Media media) async {
    if (await _isOffline()) {
      find<PendingWrites>().record(service, media, PendingKind.delete);
      return snackString(getString.offlineSaved);
    }
    await inner.deleteFromList(media);
  }

  @override
  Future<void> setProgress(Media media, int progress) async {
    if (await _isOffline()) {
      applyProgress(media, progress);
      find<PendingWrites>().record(
        service,
        media,
        PendingKind.progress,
        progress: progress,
      );
      final now = DateTime.now();
      final last = _lastNotice;
      if (last == null || now.difference(last).inMinutes >= 5) {
        _lastNotice = now;
        snackString(getString.offlineSaved);
      }
      return;
    }
    await inner.setProgress(media, progress);
    applyProgress(media, progress);
    onProgressSaved?.call(service, media);
  }
}
