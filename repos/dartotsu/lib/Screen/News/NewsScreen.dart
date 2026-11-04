import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/News.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Animation/WidgetAnimations.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Utils/Function.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import 'Components/NewsTile.dart';
import 'NewsState.dart';

class NewsScreen extends StatefulWidget {
  final NewsScreenView view;

  const NewsScreen({super.key, required this.view});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends BaseScreen<NewsScreen>
    with ScreenStateHost<NewsScreen, NewsState> {
  @override
  NewsState buildState() => NewsState(widget.view);

  @override
  Widget buildContent(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppScreenBar(title: getString.newsTitle),
    body: Watch(() => _body(context)),
  );

  Widget _body(BuildContext context) {
    final skeleton = state.first.value && state.loading.value;
    final items = state.items.toList();
    if (state.failed.value && items.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        failed: true,
        title: getString.newsCouldntLoad,
        actionLabel: getString.retry,
        onAction: () => state.load(reset: true),
      );
    }
    if (!skeleton && items.isEmpty && !state.loading.value) {
      return EmptyState(
        icon: Icons.newspaper_rounded,
        title: getString.newsEmpty,
      );
    }
    return RefreshIndicator(
      onRefresh: () => state.load(reset: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 600) state.load();
          return false;
        },
        child: ScrollConfig(
          context,
          child: Skeletonizer(
            enabled: skeleton,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                Dimens.pagePad,
                Dimens.gapSm,
                Dimens.pagePad,
                120,
              ),
              itemCount: skeleton ? 8 : items.length,
              separatorBuilder: (_, _) => SizedBox(height: Dimens.gapSm),
              itemBuilder: (context, i) {
                if (skeleton) return const NewsTile(item: NewsItem.placeholder);
                final item = items[i];
                final tile = NewsTile(
                  key: ValueKey(item.id),
                  item: item,
                  onTap: item.url.isEmpty
                      ? null
                      : () => openLinkInBrowser(item.url),
                );
                return i < 10 ? tile.animateStagger(i) : tile;
              },
            ),
          ),
        ),
      ),
    );
  }
}
