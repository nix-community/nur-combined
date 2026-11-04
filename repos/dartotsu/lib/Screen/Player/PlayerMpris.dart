import 'dart:async';

import '../../Core/State/State.dart';
import 'Engine/Mpris.dart';
import 'PlayerState.dart';

class PlayerMpris implements MprisHost {
  final PlayerState state;
  late final MprisService service = MprisService(this);
  final _subs = <Disposer>[];
  Duration _lastPosition = Duration.zero;
  DateTime _lastAt = DateTime.now();

  PlayerMpris(this.state);

  Future<void> start() async {
    await service.start();
    rebind();
  }

  void rebind() {
    if (!service.active) return;
    for (final s in _subs) {
      s.dispose();
    }
    _subs.clear();
    final engine = state.engine;
    void status(Object? _) => service.refresh(status: true);
    _subs
      ..add(engine.playing.listen(status))
      ..add(engine.buffering.listen(status))
      ..add(engine.completed.listen(status))
      ..add(engine.rate.listen((_) => service.refresh(rate: true)))
      ..add(engine.duration.listen((_) => service.refresh(metadata: true)))
      ..add(state.index.listen((_) => service.refresh(metadata: true)))
      ..add(
        engine.position.listen((at) {
          final expected =
              _lastPosition +
              (engine.playing.value
                  ? DateTime.now().difference(_lastAt)
                  : Duration.zero);
          _lastPosition = at;
          _lastAt = DateTime.now();
          if ((at - expected).abs() > const Duration(seconds: 2)) {
            service.refresh(seeked: at);
          }
        }),
      );
    service.refresh(status: true, metadata: true, rate: true);
  }

  Future<void> dispose() async {
    for (final s in _subs) {
      s.dispose();
    }
    _subs.clear();
    await service.dispose();
  }

  @override
  String get status {
    final engine = state.engine;
    if (engine.completed.value) return 'Stopped';
    return engine.playing.value ? 'Playing' : 'Paused';
  }

  @override
  double get rate => state.engine.rate.value;

  @override
  Duration get position => state.engine.position.value;

  @override
  Duration get length => state.engine.duration.value;

  @override
  String get title => state.item.title;

  @override
  String? get album => state.request.media?.mainName ?? state.item.subtitle;

  @override
  String? get art {
    final item = state.item;
    final media = state.request.media;
    return item.episode?.thumbnail ??
        item.unit?.thumbnail ??
        media?.cover ??
        media?.banner;
  }

  @override
  int get trackIndex => state.index.value;

  @override
  bool get hasNext => state.hasNext;

  @override
  bool get hasPrevious => state.hasPrevious;

  @override
  Future<void> play() => state.engine.play();

  @override
  Future<void> pause() => state.engine.pause();

  @override
  Future<void> stop() async {
    await state.engine.pause();
    await state.engine.seek(Duration.zero);
  }

  @override
  Future<void> next() async => state.openNext();

  @override
  Future<void> previous() async => state.openPrevious();

  @override
  Future<void> seekBy(Duration by) => state.engine.seekBy(by);

  @override
  Future<void> seekTo(Duration to) => state.engine.seek(to);

  @override
  Future<void> setRate(double value) => state.engine.setRate(value);
}
