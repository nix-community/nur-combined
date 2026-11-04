import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';

import '../../Logger.dart';
import '../NotificationManager/NotificationManager.dart';
import '../Preferences/PrefManager.dart';
import 'MediaServiceController.dart';
import 'Screens/NotificationAlertSettings.dart';
import '../../Screen/Notifications/NotificationOpen.dart';
import '../State/State.dart';
import '../ThemeManager/LanguageSwitcher.dart';

class ActivityAlerts extends AppController {
  static const _payload = 'notif:';

  Timer? _timer;
  bool _busy = false;
  Disposer? _tapSub;
  final _watched = <Disposer>[];

  Iterable<MediaService> get _services => find<MediaServiceController>()
      .services
      .where((s) => s.notificationView?.alertsPref != null);

  Iterable<MediaService> get _badged => find<MediaServiceController>().services
      .where((s) => s.notificationView != null);

  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _tapSub = onChange(find<NotificationManager>().tapped, _tapped);
    for (final s in _services) {
      final view = s.notificationView!;
      _watched.add(
        onChange(view.alertsPref!.rx, (on) {
          _schedule();
          if (on) unawaited(poll());
        }),
      );
      final poll_ = view.pollPref;
      if (poll_ != null) _watched.add(onChange(poll_.rx, (_) => _schedule()));
    }
    _schedule();
    unawaited(poll());
  }

  void _schedule() {
    _timer?.cancel();
    final minutes = [
      for (final s in _badged)
        (s.notificationView!.pollPref?.value ?? 5).clamp(1, 120),
    ];
    if (minutes.isEmpty) return;
    final every = minutes.reduce((a, b) => a < b ? a : b);
    _timer = Timer.periodic(Duration(minutes: every), (_) => unawaited(poll()));
  }

  Future<void> present(
    MediaService service,
    ServiceNotification n,
  ) => find<NotificationManager>().show(
    title: n.title ?? service.name,
    subtitle: service.name,
    body: n.detail ?? n.text,
    imageUrl: n.imageUrl,
    payload: canOpenNotification(n)
        ? '$_payload${jsonEncode({'s': service.id, 'm': n.mediaId, 'u': n.userId, 'a': n.activityId, 'i': n.imageUrl, 't': n.title, 'k': n.mediaIsAnime})}'
        : null,
  );

  Future<bool> sendTest(
    MediaService service,
    ServiceNotification? sample,
  ) async {
    final manager = find<NotificationManager>();
    if (!await manager.requestPermission()) return false;
    await present(
      service,
      sample ??
          ServiceNotification(
            id: 'test',
            text: getString.notificationsTestSample,
            title: service.name,
            detail: getString.notificationsTestSample,
            imageUrl: service.auth?.user.value?.avatar,
            createdAt: DateTime.now(),
          ),
    );
    return true;
  }

  void _tapped(String? payload) {
    if (payload == null || !payload.startsWith(_payload)) return;
    logger('Tapped $payload', tag: 'NOTIFICATION');
    try {
      final data =
          jsonDecode(payload.substring(_payload.length))
              as Map<String, dynamic>;
      final service = find<MediaServiceController>().services.firstWhereOrNull(
        (s) => s.id == data['s'],
      );
      if (service == null) return;
      final context = appContext;
      if (context == null || !context.mounted) return;
      openNotification(
        context,
        service,
        ServiceNotification(
          id: '',
          text: '',
          createdAt: DateTime.now(),
          mediaId: data['m'] as String?,
          userId: data['u'] as String?,
          activityId: data['a'] as String?,
          imageUrl: data['i'] as String?,
          title: data['t'] as String?,
          mediaIsAnime: data['k'] as bool?,
        ),
      );
    } catch (e, st) {
      logError('ActivityAlerts', e, st);
    }
  }

  Future<void> _refreshBadge(MediaService service) async {
    try {
      await service.auth?.refreshUser();
    } catch (e, st) {
      logError('ActivityAlerts', e, st);
    }
  }

  String _key(String serviceId) => 'activityAlerts/seenAt/$serviceId';

  Future<void> poll() async {
    if (_busy) return;
    _busy = true;
    try {
      await Future.wait([
        for (final service in _badged)
          if (service.auth?.isLoggedIn ?? false)
            if (service.notificationView!.alertsPref?.value ?? false)
              _pollService(service, service.notificationView!)
            else
              _refreshBadge(service),
      ]);
    } finally {
      _busy = false;
    }
  }

  Future<void> _pollService(
    MediaService service,
    NotificationScreenView view,
  ) async {
    try {
      final alerts = await view.unread();
      logger(
        '${service.name} poll: ${alerts.length} unread',
        tag: 'NOTIFICATION',
      );
      final shown = service.auth?.user.value?.unreadNotifications ?? 0;
      if (alerts.isNotEmpty || shown > 0) unawaited(_refreshBadge(service));
      if (alerts.isEmpty) return;
      int stamp(ServiceNotification n) => n.createdAt.millisecondsSinceEpoch;
      final newest = alerts.map(stamp).reduce((a, b) => a > b ? a : b);
      final last = PrefManager.getCustomVal<int>(_key(service.id)) ?? 0;
      if (newest <= last) return;
      PrefManager.setCustomVal<int>(_key(service.id), newest);
      final off = mutedKinds(view);
      final fresh =
          alerts
              .where((n) => stamp(n) > last && !off.contains(n.kind.name))
              .toList()
            ..sort((a, b) => stamp(a).compareTo(stamp(b)));
      logger(
        '${service.name}: ${fresh.length} new, ${alerts.length - fresh.length} skipped',
        tag: 'NOTIFICATION',
      );
      if (fresh.isEmpty) return;
      final manager = find<NotificationManager>();
      if (fresh.length > 4) {
        final latest = fresh.reversed.take(4).toList();
        await manager.show(
          title: getString.notificationsNewCount(fresh.length),
          subtitle: service.name,
          body: [for (final n in latest) '• ${n.text}'].join('\n'),
          imageUrl: fresh.last.imageUrl,
        );
        return;
      }
      for (final alert in fresh) {
        await present(service, alert);
      }
    } catch (e) {
      logger(
        '${service.name} poll failed: $e',
        logLevel: LogLevel.error,
        tag: 'NOTIFICATION',
      );
    }
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
