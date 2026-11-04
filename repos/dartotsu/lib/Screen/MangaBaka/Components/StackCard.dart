import 'package:flutter/material.dart';

import '../../../Api/Services/MangaBaka/Data/Community.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/CachedNetworkImage.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Components/SectionCard.dart';

class StackCovers extends StatelessWidget {
  final List<String> covers;
  final double height;

  const StackCovers({super.key, required this.covers, this.height = 84});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final width = height * 0.68;
    final shown = covers.take(3).toList();
    final step = width * 0.42;
    return SizedBox(
      width: width + step * (shown.length < 2 ? 0 : shown.length - 1),
      height: height,
      child: Stack(
        children: [
          for (var i = shown.length - 1; i >= 0; i--)
            PositionedDirectional(
              start: step * i,
              top: 0,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: cachedNetworkImage(
                  imageUrl: shown[i],
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                ),
              ),
            ),
          if (shown.isEmpty)
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.collections_bookmark_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class StackCard extends StatelessWidget {
  final MangaBakaStack stack;
  final VoidCallback? onTap;
  final VoidCallback? onOwner;

  const StackCard({super.key, required this.stack, this.onTap, this.onOwner});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    final tags = [
      if (stack.featured) (getString.stacksFeatured, scheme.primary),
      if (stack.spoiler) (getString.stackSpoilers, scheme.tertiary),
    ];
    return Clickable(
      onTap: onTap,
      child: SectionCard(
        padding: EdgeInsets.all(Dimens.cardPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StackCovers(covers: stack.covers),
            SizedBox(width: Dimens.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stack.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (stack.owner.username.isNotEmpty) ...[
                    SizedBox(height: Dimens.gapXs),
                    Clickable(
                      onTap: onOwner,
                      child: Text(
                        getString.stackBy(stack.owner.label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: onOwner == null
                              ? scheme.onSurfaceVariant
                              : scheme.primary,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: Dimens.gapXs),
                  Text(
                    [
                      getString.stackSeriesCount(stack.entryCount),
                      getString.stackSavesCount(stack.saveCount),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    SizedBox(height: Dimens.gapSm),
                    Wrap(
                      spacing: Dimens.gapXs,
                      children: [
                        for (final (label, color) in tags)
                          Chip(
                            label: Text(label),
                            visualDensity: VisualDensity.compact,
                            labelStyle: text.labelSmall?.copyWith(color: color),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
