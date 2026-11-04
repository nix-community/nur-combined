import 'package:flutter/material.dart';

import '../../../Core/Services/Model/News.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Functions/TimeAgo.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Components/SectionCard.dart';
import '../../MangaBaka/Components/StackCard.dart';

class NewsTile extends StatelessWidget {
  final NewsItem item;
  final VoidCallback? onTap;

  const NewsTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    final published = item.published;
    final covers = [
      for (final m in item.series)
        if (m.cover != null) m.cover!,
    ];
    return Clickable(
      onTap: onTap,
      child: SectionCard(
        padding: EdgeInsets.all(Dimens.cardPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (covers.isNotEmpty) ...[
              StackCovers(covers: covers.take(1).toList(), height: 72),
              SizedBox(width: Dimens.gap),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Dimens.gapXs),
                  Text(
                    [
                      item.source,
                      if (item.author != null && item.author!.isNotEmpty)
                        item.author!,
                      if (published != null)
                        timeAgo(published.millisecondsSinceEpoch ~/ 1000),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
