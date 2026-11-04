import 'dart:async';
import 'dart:io';

import 'package:flutter_media_session/flutter_media_session.dart';

import '../../Core/State/State.dart';
import '../../Logger.dart';
import 'PlayerMpris.dart';
import 'PlayerState.dart';

bool get mediaSessionSupported =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isMacOS ||
    Platform.isWindows ||
    Platform.isLinux;

class PlayerMediaSession implements MediaSessionAdapter {
  final PlayerState state;
  final _session = FlutterMediaSession();
  final _subs = <Disposer>[];
  StreamSubscription<MediaAction>? _actions;
  Disposer? _indexSub;
  bool _active = false;
  Duration _lastReported = Duration.zero;
  DateTime _lastReportedAt = DateTime.now();

  PlayerMpris? _mpris;

  PlayerMediaSession(this.state);

  Future<void> start() async {
    if (_active || !mediaSessionSupported) return;
    if (Platform.isLinux) {
      final mpris = _mpris = PlayerMpris(state);
      await mpris.start();
      _active = true;
      return;
    }
    try {
      if (Platform.isAndroid) {
        await FlutterMediaSessionPlatform.instance
            .requestNotificationPermission();
      }
      await _session.activate();
      final seek = state.settings.seekDuration;
      await _session.setSkipIntervals(
        forwardSeconds: seek,
        backwardSeconds: seek,
      );
      _session.bind(this);
      _active = true;
      _actions = FlutterMediaSessionPlatform.instance.onMediaAction.listen(
        _onAction,
        onError: (Object e, StackTrace st) =>
            logError('MediaSession', e, st, 'action stream failed'),
      );
      _indexSub = state.index.listen((_) => _afterItemChange());
      rebind();
      await _actionsAvailable();
      await _metadata();
      await _playback();
    } catch (e, st) {
      logError('MediaSession', e, st, 'start failed');
    }
  }

  void rebind() {
    if (!_active) return;
    if (_mpris != null) return _mpris!.rebind();
    for (final s in _subs) {
      s.dispose();
    }
    _subs.clear();
    final engine = state.engine;
    void changed(Object? _) => unawaited(_playback());
    _subs
      ..add(engine.playing.listen(changed))
      ..add(engine.buffering.listen(changed))
      ..add(engine.completed.listen(changed))
      ..add(engine.rate.listen(changed))
      ..add(
        engine.duration.listen((_) {
          unawaited(_metadata());
          unawaited(_playback());
        }),
      )
      ..add(
        engine.position.listen((at) {
          final expected =
              _lastReported +
              (engine.playing.value
                  ? DateTime.now().difference(_lastReportedAt)
                  : Duration.zero);
          if ((at - expected).abs() > const Duration(seconds: 2)) {
            unawaited(_playback());
          }
        }),
      );
  }

  void _afterItemChange() {
    unawaited(_actionsAvailable());
    unawaited(_metadata());
  }

  Future<void> _onAction(MediaAction action) async {
    final engine = state.engine;
    try {
      switch (action.name) {
        case 'play':
          await engine.play();
        case 'pause':
          await engine.pause();
        case 'stop':
          await engine.pause();
          await engine.seek(Duration.zero);
        case 'seekTo':
          final at = action.seekPosition;
          if (at != null) await engine.seek(at);
        case 'rewind':
          await engine.seekBy(Duration(seconds: -state.settings.seekDuration));
        case 'fastForward':
          await engine.seekBy(Duration(seconds: state.settings.seekDuration));
        case 'skipToNext':
          state.openNext();
        case 'skipToPrevious':
          state.openPrevious();
      }
    } catch (e, st) {
      logError('MediaSession', e, st, 'action ${action.name} failed');
    }
  }

  Future<void> _metadata() async {
    if (!_active) return;
    final item = state.item;
    final media = state.request.media;
    try {
      await FlutterMediaSessionPlatform.instance.updateMetadata(
        MediaMetadata(
          title: item.title,
          artist: media?.mainName ?? item.subtitle,
          album: media?.mainName ?? item.subtitle,
          artworkUri:
              item.episode?.thumbnail ??
              item.unit?.thumbnail ??
              media?.cover ??
              media?.banner,
          duration: state.engine.duration.value,
        ),
      );
    } catch (e, st) {
      logError('MediaSession', e, st, 'metadata failed');
    }
  }

  Future<void> _playback() async {
    if (!_active) return;
    final engine = state.engine;
    final status = engine.buffering.value
        ? PlaybackStatus.buffering
        : engine.completed.value
        ? PlaybackStatus.ended
        : engine.playing.value
        ? PlaybackStatus.playing
        : PlaybackStatus.paused;
    _lastReported = engine.position.value;
    _lastReportedAt = DateTime.now();
    try {
      await FlutterMediaSessionPlatform.instance.updatePlaybackState(
        PlaybackState(
          status: status,
          position: _lastReported,
          speed: engine.rate.value,
          bufferedPosition: engine.buffer.value,
        ),
      );
    } catch (e, st) {
      logError('MediaSession', e, st, 'playback state failed');
    }
  }

  Future<void> _actionsAvailable() async {
    if (!_active) return;
    try {
      await FlutterMediaSessionPlatform.instance.updateAvailableActions({
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.seekTo,
        MediaAction.fastForward,
        MediaAction.rewind,
        if (state.hasNext) MediaAction.skipToNext,
        if (state.hasPrevious) MediaAction.skipToPrevious,
      });
    } catch (e, st) {
      logError('MediaSession', e, st, 'actions failed');
    }
  }

  @override
  void bind(FlutterMediaSession session) {}

  @override
  void unbind() {}

  Future<void> dispose() async {
    final was = _active;
    _active = false;
    final mpris = _mpris;
    _mpris = null;
    if (mpris != null) {
      await mpris.dispose();
      return;
    }
    for (final s in _subs) {
      s.dispose();
    }
    _subs.clear();
    _indexSub?.dispose();
    await _actions?.cancel();
    _actions = null;
    if (!was) return;
    try {
      _session.unbind();
      await _session.deactivate();
    } catch (e, st) {
      logError('MediaSession', e, st, 'deactivate failed');
    }
  }
}
