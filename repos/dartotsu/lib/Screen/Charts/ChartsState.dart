import 'dart:async';

import '../../Core/Services/Api/AniTrendz.dart';
import '../../Core/State/State.dart';
import '../../Logger.dart';
import '../../Widgets/Components/ScreenState.dart';

class ChartsState extends ScreenState {
  final chart = TrendzChart.anime.live;
  final week = Live<TrendzWeek?>(null);
  final loading = true.live;
  final error = Live<String?>(null);
  int _run = 0;

  @override
  void onInit() => unawaited(load());

  void select(TrendzChart value) {
    if (chart.value == value) return;
    chart.value = value;
    unawaited(load());
  }

  Future<void> load({bool force = false}) async {
    final run = ++_run;
    loading.value = true;
    error.value = null;
    if (force) week.value = null;
    try {
      final result = await AniTrendz.chart(chart.value, force: force);
      if (run != _run) return;
      week.value = result;
    } catch (e, st) {
      if (run != _run) return;
      logger(
        'AniTrendz failed: $e\n$st',
        logLevel: LogLevel.warning,
        tag: 'CHARTS',
      );
      week.value = null;
      error.value = '$e';
    } finally {
      if (run == _run) loading.value = false;
    }
  }
}
