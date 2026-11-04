import '../../Logger.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';

class ShelfState extends ScreenState {
  final String title;
  final Future<List<Media>?> Function()? loader;

  ShelfState({
    required this.title,
    required List<Media> media,
    required this.loader,
  }) : items = [...media].liveList,
       more = (loader != null).live {
    known = {for (final m in items) m.id};
  }

  final LiveList<Media> items;
  late final Set<String> known;
  final loading = false.live;
  final Live<bool> more;

  DiscordPresence get presence =>
      DiscordPresence.browsing('Browsing a list', state: title);

  @override
  void onInit() {
    if (more.value && items.length < 24) {
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(next()));
    }
  }

  Future<void> next() async {
    final load = loader;
    if (load == null || loading.value || !more.value) return;
    loading.value = true;
    try {
      final batch = await load();
      if (!mounted) return;
      final fresh = [
        for (final m in batch ?? const <Media>[])
          if (known.add(m.id)) m,
      ];
      items.addAll(fresh);
      more.value = fresh.isNotEmpty;
    } catch (e, st) {
      logError('ShelfState', e, st);
      if (mounted) more.value = false;
    } finally {
      if (mounted) loading.value = false;
    }
    if (mounted && more.value && items.length < 24) unawaited(next());
  }

  bool onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical && n.metrics.extentAfter < 700) {
      unawaited(next());
    }
    return false;
  }
}
