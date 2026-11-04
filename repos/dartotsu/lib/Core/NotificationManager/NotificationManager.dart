import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;

import '../../Logger.dart';
import '../NetworkManager/NetworkManager.dart';
import '../Preferences/StorageManager.dart';
import '../State/State.dart';

class NotificationManager extends AppController {
  static const _channel = AndroidNotificationDetails(
    'default',
    'Default',
    channelDescription: 'General notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  final _plugin = FlutterLocalNotificationsPlugin();
  final permissionGranted = false.live;
  final tapped = Live<String?>(null);

  bool _ready = false;
  int _nextId =
      10000 + DateTime.now().millisecondsSinceEpoch ~/ 1000 % 1000000000;

  Future<void> initialize() async {
    if (_ready) return;
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open',
          defaultIcon: AssetsLinuxIcon('assets/images/logo.png'),
        ),
        windows: const WindowsInitializationSettings(
          appName: 'Dartotsu',
          appUserModelId: 'ani.aayush262.dartotsu',
          guid: '6f1d6c2e-3b7a-4c58-9e0d-5a2b8c4f7e91',
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        logger(
          'Response ${r.notificationResponseType.name} id ${r.id} action ${r.actionId} payload ${r.payload}',
          tag: 'NOTIFICATION',
        );
        tapped.value = r.payload;
        tapped.value = null;
      },
    );
    permissionGranted.value = await requestPermission();
    _ready = true;
    unawaited(_sweepImages());
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (Platform.isMacOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  Future<void> _sweepImages() async {
    try {
      final dir = await StorageManager.getTmpDirectory();
      final cutoff = DateTime.now().subtract(const Duration(days: 3));
      await for (final entity in dir!.list()) {
        if (entity is! File ||
            !p.basename(entity.path).startsWith('notification_')) {
          continue;
        }
        if ((await entity.lastModified()).isBefore(cutoff)) {
          await entity.delete();
        }
      }
    } catch (e, st) {
      logError('NotificationManager', e, st);
    }
  }

  Future<String?> _fetch(String? url) async {
    if (url == null || url.isEmpty || kIsWeb) return null;
    try {
      final dir = await StorageManager.getTmpDirectory();
      final name = url.hashCode.toUnsigned(32).toRadixString(16);
      final file = File(p.join(dir!.path, 'notification_$name.jpg'));
      if (!await file.exists() || await file.length() == 0) {
        await find<NetworkManager>().download(url, file.path);
      }
      return await file.exists() && await file.length() > 0 ? file.path : null;
    } catch (e) {
      logger(
        'Image download failed ($url): $e',
        logLevel: LogLevel.error,
        tag: 'NOTIFICATION',
      );
      return null;
    }
  }

  Future<void> show({
    required String title,
    required String body,
    String? subtitle,
    String? imageUrl,
    int? id,
    String? payload,
  }) async {
    if (!_ready) await initialize();
    final image = await _fetch(imageUrl);
    logger(
      'Show "$title" · $body${subtitle == null ? '' : ' [$subtitle]'}'
      '${image == null ? '' : ' +image'}',
      tag: 'NOTIFICATION',
    );
    final android = AndroidNotificationDetails(
      _channel.channelId,
      _channel.channelName,
      channelDescription: _channel.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      subText: subtitle,
      largeIcon: image == null ? null : FilePathAndroidBitmap(image),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: subtitle,
      ),
    );
    final darwin = DarwinNotificationDetails(
      subtitle: subtitle,
      attachments: image == null ? null : [DarwinNotificationAttachment(image)],
    );
    await _plugin.show(
      id: id ?? ++_nextId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: LinuxNotificationDetails(
          icon: image == null ? null : FilePathLinuxIcon(image),
        ),
      ),
      payload: payload,
    );
  }

  Future<void> showProgress({
    required int id,
    required String title,
    required String body,
    required int percent,
    String? payload,
  }) async {
    if (!_ready) await initialize();
    if (!Platform.isAndroid) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'downloads',
          'Downloads',
          channelDescription: 'Download progress',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: percent.clamp(0, 100),
          indeterminate: percent < 0,
          ongoing: true,
          onlyAlertOnce: true,
          autoCancel: false,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  void onClose() {
    tapped.close();
    permissionGranted.close();
    super.onClose();
  }
}
