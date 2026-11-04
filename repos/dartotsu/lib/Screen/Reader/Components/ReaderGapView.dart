import 'package:flutter/material.dart';

import '../Engine/ReaderItems.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../Detail/Watch/Components/UnitTile.dart';
import '../ReaderState.dart';

class ReaderGapView extends StatelessWidget {
  final ReaderState state;
  final ReaderGap gap;
  final bool fill;

  const ReaderGapView({
    super.key,
    required this.state,
    required this.gap,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final scheme = context.colorScheme;
    final target = gap.target;
    final label = target == null ? null : unitLabel(state.units[target], false);
    final loaded = !gap.atStart && state.nextLoaded(gap.chapter);
    final loading = !gap.atStart && state.loadingNext.value && !loaded;
    final current = unitLabel(state.units[gap.chapter], false);
    final lines = <Widget>[
      if (!gap.atStart)
        Text(
          getString.readerFinishedChapter(current),
          style: context.textTheme.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      SizedBox(height: Dimens.gapSm),
      if (label == null)
        Text(
          gap.atStart
              ? getString.readerFirstChapter
              : getString.readerLastChapter,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        )
      else ...[
        Text(
          gap.atStart
              ? getString.readerPreviousUp(label)
              : getString.readerNextUp(label),
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimens.gap),
        if (loading)
          const CircularProgressIndicator()
        else if (!loaded)
          FilledButton.tonal(
            onPressed: gap.atStart
                ? () => state.openChapter(target!, atEnd: true)
                : state.loadNextNow,
            child: Text(
              gap.atStart
                  ? getString.readerPreviousChapter
                  : getString.readerNextChapter,
            ),
          ),
      ],
    ];
    final content = Container(
      margin: EdgeInsets.all(Dimens.pagePad),
      padding: EdgeInsets.all(Dimens.pagePad),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            gap.atStart
                ? Icons.keyboard_double_arrow_up_rounded
                : Icons.keyboard_double_arrow_down_rounded,
            color: scheme.primary,
            size: 32,
          ),
          SizedBox(height: Dimens.gapSm),
          ...lines,
        ],
      ),
    );
    return fill ? Center(child: content) : content;
  }
}
