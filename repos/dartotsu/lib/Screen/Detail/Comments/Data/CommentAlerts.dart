import 'dart:async';

import '../../../../Api/Services/Anilist/AnilistService.dart';
import '../../../Feed/FeedNavigation.dart';
import '../../../../Logger.dart';
import '../../../../Core/NotificationManager/NotificationManager.dart';
import '../../../../Core/Preferences/PrefManager.dart';
import '../../../../Core/Services/MediaServiceController.dart';
import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Api/Services/Anilist/Auth.dart';
import 'CommentModels.dart';
import 'CommentNoticeStore.dart';
import 'CommentsApi.dart';

class CommentAlerts extends AppController {
  static const _payload = 'comment:';
  static const _seenKey = 'commentAlerts/seen';
  static const _globalKey = 'commentAlerts/global';

  Timer? _timer;
  bool _busy = false;
  Disposer? _tapSub;
  final _watched = <Disposer>[];

  CommentsApi get _api => find<CommentsApi>();

  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _schedule();
    _watched.add(onChange(PrefName.commentsPollMinutes.rx, (_) => _schedule()));
    _tapSub = onChange(find<NotificationManager>().tapped, _tapped);
    _watched.add(
      onChange(PrefName.commentsAlerts.rx, (on) {
        if (on) unawaited(poll());
      }),
    );
    unawaited(poll());
  }

  void _schedule() {
    _timer?.cancel();
    final minutes = PrefName.commentsPollMinutes.value.clamp(1, 120);
    _timer = Timer.periodic(
      Duration(minutes: minutes),
      (_) => unawaited(poll()),
    );
  }

  Future<void> poll() async {
    if (!PrefName.commentsAlerts.value) return;
    await sync(notify: true);
  }

  Future<List<CommentNotice>> sync({required bool notify}) async {
    if (_busy || !_api.enabled || !_api.hasToken) {
      return CommentNoticeStore.load();
    }
    _busy = true;
    try {
      if (await _api.ensureSession() == null) return CommentNoticeStore.load();
      final found = await _api.notices();
      logger('Comments poll: ${found.length} notices', tag: 'NOTIFICATION');
      final stored = CommentNoticeStore.load();
      final known = {for (final n in stored) n.key};
      final global = PrefManager.getCustomVal<int>(_globalKey) ?? 0;
      final info = await _mediaInfo({
        for (final n in found)
          if (n.isReply || n.isWarning) n.mediaId,
      });
      final now = DateTime.now().millisecondsSinceEpoch;
      final enriched = [
        for (final n in found)
          if (!n.isSilent)
            n.copyWith(
              receivedAt: now,
              mediaTitle: info[n.mediaId]?.$1,
              cover: info[n.mediaId]?.$2,
            ),
      ];
      final fresh = [
        for (final n in enriched)
          if (n.isGlobal ? n.id > global : !known.contains(n.key)) n,
      ]..sort((a, b) => a.id.compareTo(b.id));
      final merged = CommentNoticeStore.merge(stored, enriched);
      CommentNoticeStore.save(merged);
      markSeen(found);
      if (notify) {
        final manager = find<NotificationManager>();
        for (final n in fresh) {
          final (title, body) = _text(n);
          await manager.show(
            title: title,
            subtitle: getString.comments,
            body: body,
            imageUrl: n.cover,
            payload: n.isReply || n.isWarning
                ? '$_payload${n.mediaId}:${n.commentId}'
                : null,
          );
        }
      }
      return merged;
    } catch (e) {
      logger(
        'Comments poll failed: $e',
        logLevel: LogLevel.error,
        tag: 'NOTIFICATION',
      );
      return CommentNoticeStore.load();
    } finally {
      _busy = false;
    }
  }

  Future<Map<int, (String, String?)>> _mediaInfo(Set<int> ids) async {
    if (ids.isEmpty) return const {};
    try {
      final data = await anilistAuth.client.query(
        '{Page(perPage: 50){media(id_in: [${ids.join(',')}]){id title{userPreferred} coverImage{large}}}}',
        showErrors: false,
      );
      return {
        for (final m in ((data['Page'] as Map?)?['media'] as List?) ?? const [])
          if (m is Map && m['id'] is int)
            m['id'] as int: (
              (m['title'] as Map?)?['userPreferred'] as String? ?? '',
              (m['coverImage'] as Map?)?['large'] as String?,
            ),
      };
    } catch (e, st) {
      logError('CommentAlerts', e, st);
      return const {};
    }
  }

  void markSeen(List<CommentNotice> found) {
    final seen = PrefManager.getCustomVal<int>(_seenKey) ?? 0;
    final global = PrefManager.getCustomVal<int>(_globalKey) ?? 0;
    final newestGlobal = found
        .where((n) => n.isGlobal)
        .fold<int>(global, (m, n) => n.id > m ? n.id : m);
    final newest = found
        .where((n) => !n.isGlobal)
        .fold<int>(seen, (m, n) => n.id > m ? n.id : m);
    PrefManager.setCustomVal<int>(_globalKey, newestGlobal);
    PrefManager.setCustomVal<int>(_seenKey, newest);
  }

  (String, String) _text(CommentNotice n) {
    if (n.isWarning) {
      return (
        getString.commentsNoticeWarningTitle,
        n.content ?? getString.commentsNoticeWarning,
      );
    }
    if (n.isAnnouncement) {
      return (getString.commentsNoticeUpdateTitle, n.content ?? '');
    }
    final media = n.mediaTitle;
    return (
      getString.commentsNoticeReplyTitle,
      media == null || media.isEmpty
          ? getString.commentsNoticeReply(n.username)
          : getString.commentsNoticeReplyIn(n.username, media),
    );
  }

  void _tapped(String? payload) {
    if (payload == null || !payload.startsWith(_payload)) return;
    logger('Tapped $payload', tag: 'NOTIFICATION');
    final parts = payload.substring(_payload.length).split(':');
    if (parts.length != 2) return;
    final mediaId = parts[0];
    final commentId = int.tryParse(parts[1]);
    unawaited(open(mediaId, commentId));
  }

  Future<void> open(String mediaId, int? commentId) async {
    final context = appContext;
    if (context == null) return;
    final anilist = find<MediaServiceController>().services.firstWhere(
      (s) => s.id == anilistServiceId,
    );
    final media = await anilist.getQueries?.getMedia(mediaId);
    if (media == null || !context.mounted) return;
    openDetail(context, anilist, media, commentId: commentId);
  }

  @override
  void onClose() {
    _timer?.cancel();
    _tapSub?.dispose();
    for (final d in _watched) {
      d.dispose();
    }
    super.onClose();
  }
}
