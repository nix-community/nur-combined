import '../../../Core/Preferences/Incognito.dart';
import '../../../Core/Services/Api/Mutations.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/RefreshController.dart';
import '../../../Utils/Functions/SnackBar.dart';
import 'Client.dart';
import 'Queries.dart';

class MangaUpdatesMutations extends Mutations {
  final MangaUpdatesClient client;
  final MangaUpdatesQueries queries;

  MangaUpdatesMutations(this.client, this.queries);

  int _listIdFor(String? status) => switch (status) {
    'CURRENT' => 0,
    'PLANNING' => 1,
    'COMPLETED' => 2,
    'DROPPED' => 3,
    'PAUSED' => 4,
    'REPEATING' => 0,
    _ => 0,
  };

  int? _idOf(Media media) => MangaUpdatesQueries.cleanId(media.id);

  void _done() {
    queries.invalidateLibrary();
    tryFind<RefreshController>()?.all();
  }

  @override
  Future<void> editList(Media media, {List<String>? customList}) async {
    if (incognitoBlocksEdits) {
      snackString(getString.incognitoEditsBlocked);
      return;
    }
    try {
      await saveEntry(media);
      _done();
    } on MangaUpdatesException catch (e) {
      snackString(getString.serviceError(getString.mangaUpdates, e.message));
    }
  }

  Map<String, Object?> _entry(Media media, int id) => {
    'series': {'id': id},
    'list_id': _listIdFor(media.userStatus),
    'status': {'chapter': media.userProgress ?? 0},
  };

  Future<void> _rate(Media media, int id) async {
    final score = media.userScore ?? 0;
    if (score <= 0) return;
    await client.put('/series/$id/rating', {
      'rating': (score / 10).clamp(1.0, 10.0),
    });
  }

  bool _missing(MangaUpdatesException e) => e.status == 400 || e.status == 404;

  @override
  Future<void> saveEntry(Media media, {bool? exists}) async {
    final id = _idOf(media);
    if (id == null) return;
    final body = [_entry(media, id)];
    if (exists == false) {
      await client.post('/lists/series', body);
    } else {
      try {
        await client.post('/lists/series/update', body);
      } on MangaUpdatesException catch (e) {
        if (exists == true || !_missing(e)) rethrow;
        await client.post('/lists/series', body);
      }
    }
    await _rate(media, id);
  }

  Future<void> saveEntries(List<(Media, bool?)> items) async {
    final adds = <(Media, int)>[];
    final updates = <(Media, int, bool?)>[];
    for (final (media, exists) in items) {
      final id = _idOf(media);
      if (id == null) continue;
      if (exists == false) {
        adds.add((media, id));
      } else {
        updates.add((media, id, exists));
      }
    }
    if (adds.isNotEmpty) {
      await client.post('/lists/series', [
        for (final (media, id) in adds) _entry(media, id),
      ]);
    }
    var updated = true;
    if (updates.isNotEmpty) {
      try {
        await client.post('/lists/series/update', [
          for (final (media, id, _) in updates) _entry(media, id),
        ]);
      } on MangaUpdatesException catch (e) {
        if (!_missing(e)) rethrow;
        updated = false;
        for (final (media, _, exists) in updates) {
          await saveEntry(media, exists: exists);
        }
      }
    }
    for (final (media, id) in adds) {
      await _rate(media, id);
    }
    if (!updated) return;
    for (final (media, id, _) in updates) {
      await _rate(media, id);
    }
  }

  @override
  Future<void> deleteFromList(Media media) async {
    final id = _idOf(media);
    if (id == null) return;
    try {
      await client.post('/lists/series/delete', [id]);
      await client.delete('/series/$id/rating');
      clearListEntry(media);
      _done();
    } on MangaUpdatesException catch (e) {
      snackString(getString.serviceError(getString.mangaUpdates, e.message));
    }
  }

  @override
  Future<void> setProgress(Media media, int progress) async {
    if (incognitoBlocksEdits) return;
    final total = media.totalUnits;
    final done =
        media.status == 'FINISHED' &&
        total != null &&
        total > 0 &&
        progress >= total;
    media.userProgress = progress;
    if (done) {
      media.userStatus = 'COMPLETED';
    } else if (media.userStatus == null || media.userStatus == 'PLANNING') {
      media.userStatus = 'CURRENT';
    }
    try {
      await saveEntry(media);
      _done();
    } on MangaUpdatesException catch (e) {
      snackString(getString.serviceError(getString.mangaUpdates, e.message));
    }
  }
}
