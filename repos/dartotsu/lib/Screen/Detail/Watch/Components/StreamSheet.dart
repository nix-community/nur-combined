import 'package:dartotsu_extension_bridge/Models/Video.dart' as v;
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import '../../../Player/Engine/PlayRequest.dart';
import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../Data/EpisodeUnits.dart';
import '../../../../Logger.dart';
import '../../../../Utils/Extensions/ContextExtensions.dart';
import '../../../../Utils/Functions/NavigateToScreen.dart';
import '../../../../Widgets/Components/AppSheet.dart';
import '../../../../Widgets/Components/EmptyState.dart';
import '../WatchState.dart';
import 'StreamGroups.dart';
import 'UnitTile.dart';

class StreamSheet extends StatefulWidget {
  final WatchState state;
  final WatchUnit unit;

  const StreamSheet({super.key, required this.state, required this.unit});

  @override
  State<StreamSheet> createState() => _StreamSheetState();
}

class _StreamSheetState extends State<StreamSheet> {
  final _streams = Live<List<v.Video>?>(null);
  final _error = Live<String?>(null);
  late final _auto = widget.state.record.streams.auto.live;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _streams.value = null;
    _error.value = null;
    final source = widget.state.source.value;
    if (source == null) {
      _error.value = getString.watchSourceMissing;
      return;
    }
    try {
      final list = await source.methods.getVideoList(widget.unit.raw);
      if (!mounted) return;
      shareSubtitles(list);
      final last = widget.state.record.streams.last[source.id];
      final remembered = widget.state.record.streams.auto && last != null
          ? bestStreamIndex(list, last)
          : null;
      if (remembered != null || list.length == 1) {
        popPage(context, StreamPick(list, remembered ?? 0));
        return;
      }
      _streams.value = list;
      if (list.isEmpty) _error.value = getString.playerNoStreams;
    } catch (e, st) {
      logger('Streams failed: $e\n$st', logLevel: LogLevel.error, tag: 'WATCH');
      if (mounted) _error.value = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppSheet(
      title: unitLabel(widget.unit, true),
      child: Watch(() {
        final list = _streams.value;
        final error = _error.value;
        if (error != null) {
          return SizedBox(
            height: 300,
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              failed: true,
              title: getString.playerNoStreamsTitle,
              message: error,
              actionLabel: getString.retry,
              onAction: _load,
            ),
          );
        }
        if (list == null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  getString.playerLoadingStreams,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              value: _auto.value,
              title: Text(getString.playerAutoSelect),
              subtitle: Text(getString.playerAutoSelectDesc),
              onChanged: (value) {
                _auto.value = value;
                widget.state.record.streams.auto = value;
                widget.state.saveRecord();
              },
            ),
            GroupedStreams(
              list: list,
              icon: Icons.play_circle_outline_rounded,
              onPick: (i) => popPage(context, StreamPick(list, i)),
            ),
          ],
        );
      }),
    );
  }
}
