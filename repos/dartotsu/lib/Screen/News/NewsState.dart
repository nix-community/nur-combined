import 'dart:async';

import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/News.dart';
import '../../Core/State/State.dart';
import '../../Logger.dart';
import '../../Widgets/Components/ScreenState.dart';

class NewsState extends ScreenState {
  final NewsScreenView view;

  NewsState(this.view);

  final items = <NewsItem>[].liveList;
  final loading = false.live;
  final failed = false.live;
  final first = true.live;
  final hasNext = true.live;
  int _page = 1;
  int _run = 0;

  @override
  void onInit() => unawaited(load(reset: true));

  Future<void> load({bool reset = false}) async {
    if (reset) {
      _run++;
      items.clear();
      _page = 1;
      hasNext.value = true;
      failed.value = false;
      first.value = true;
      loading.value = false;
    }
    if (loading.value || !hasNext.value) return;
    final run = _run;
    loading.value = true;
    try {
      final page = await view.news(page: _page);
      if (run != _run) return;
      final known = {for (final n in items) n.id};
      items.addAll(page.items.where((n) => !known.contains(n.id)));
      hasNext.value = page.hasNext;
      if (page.hasNext) _page++;
      failed.value = false;
    } catch (e, st) {
      logError('NewsState', e, st);
      if (run == _run) failed.value = true;
    } finally {
      if (run == _run) {
        loading.value = false;
        first.value = false;
      }
    }
  }
}
