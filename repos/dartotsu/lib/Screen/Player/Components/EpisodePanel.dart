import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Widgets/Components/SheetTile.dart';
import '../PlayerState.dart';

class EpisodePanel extends StatelessWidget {
  final PlayerState state;

  const EpisodePanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final scheme = context.colorScheme;
    final items = state.items;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getString.playerEpisodes,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => state.panel.value = false,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                itemCount: items.length,
                itemBuilder: (context, i) =>
                    EpisodeTile(state: state, index: i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EpisodeTile extends StatelessWidget {
  final PlayerState state;
  final int index;

  const EpisodeTile({super.key, required this.state, required this.index});

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final item = state.items[index];
    final current = state.index.value;
    final saved = state.record?.playback[item.key];
    return SheetTile(
      tinted: true,
      radius: BorderRadius.circular(16),
      leading: Text(
        item.number == item.number.roundToDouble()
            ? '${item.number.toInt()}'
            : '${item.number}',
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: saved == null || saved.duration <= 0
          ? null
          : LinearProgressIndicator(
              value: saved.fraction.clamp(0.0, 1.0),
              minHeight: 3,
            ),
      selected: index == current,
      trailing: index == current
          ? const Icon(Icons.play_arrow_rounded)
          : const SizedBox.shrink(),
      onTap: () {
        if (index != current) state.loadItem(index);
      },
    );
  }
}
