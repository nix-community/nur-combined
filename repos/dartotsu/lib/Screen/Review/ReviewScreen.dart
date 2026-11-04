import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/Services/ScoreFormat.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Utils/Function.dart';
import '../../Widgets/Components/AniHtml.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/CachedNetworkImage.dart';
import '../../Widgets/Components/Clickable.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../../Widgets/Components/SectionCard.dart';
import '../../Widgets/Components/UserAvatar.dart';
import '../Social/Components/AniMediaCard.dart';
import '../Social/SocialNavigation.dart';
import 'ReviewCard.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ReviewState.dart';

class ReviewScreen extends StatefulWidget {
  final Review review;
  final MediaService service;
  final DetailScreenView? view;

  const ReviewScreen({
    super.key,
    required this.review,
    required this.service,
    this.view,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends BaseScreen<ReviewScreen>
    with ScreenStateHost<ReviewScreen, ReviewState> {
  @override
  bool get safeArea => false;

  @override
  ReviewState buildState() => ReviewState(
    initial: widget.review,
    service: widget.service,
    view: widget.view,
  );

  @override
  Widget buildContent(BuildContext context) {
    final scheme = context.colorScheme;
    final review = widget.review;
    final user = review.user;
    final url = review.siteUrl;
    final score = ScoreFormat.current.format(review.score ?? 0);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollConfig(
        context,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: scheme.surface,
              expandedHeight: 230,
              leadingWidth: 44,
              leading: const AppBackButton(),
              actions: [
                if (url != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded),
                    onPressed: () => openLinkInBrowser(url),
                  ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, box) {
                  final top = MediaQuery.paddingOf(context).top;
                  final min = kToolbarHeight + top;
                  final open = ((box.maxHeight - min) / (230 - min)).clamp(
                    0.0,
                    1.0,
                  );
                  return FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 56,
                      bottom: 14,
                    ),
                    title: user == null
                        ? null
                        : Clickable(
                            onTap: () =>
                                openReviewer(context, widget.service, review),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (open < 0.5) ...[
                                  UserAvatar(
                                    url: user.pfp,
                                    name: user.name,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  user.name,
                                  style: context.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (user?.banner != null)
                          cachedNetworkImage(
                            imageUrl: user!.banner,
                            fit: BoxFit.cover,
                          )
                        else
                          ColoredBox(color: scheme.surfaceContainerHigh),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                scheme.surface.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                        if (user != null)
                          Align(
                            alignment: const Alignment(0, -0.25),
                            child: Clickable(
                              onTap: () =>
                                  openReviewer(context, widget.service, review),
                              child: UserAvatar(
                                url: user.pfp,
                                name: user.name,
                                size: 84,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                Dimens.gap,
                Dimens.gapSm,
                Dimens.gap,
                Dimens.gapXl,
              ),
              sliver: SliverList.list(
                children: [
                  if (score.isNotEmpty || review.createdAt != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: Dimens.gapSm),
                      child: Row(
                        children: [
                          if (score.isNotEmpty)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(score),
                              avatar: const Icon(Icons.star_rounded, size: 16),
                            ),
                          if (review.createdAt != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              ReviewCard.date(review.createdAt!),
                              style: context.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  SectionCard(
                    title: review.summary,
                    child: SelectionArea(
                      child: AniHtml(
                        html: review.body ?? '',
                        onLink: (link) =>
                            openAppLink(context, widget.service, link),
                        linkCard: aniLinkCards(widget.service),
                      ),
                    ),
                  ),
                  if (state.canVote) ...[
                    SizedBox(height: Dimens.gapSm),
                    _votes(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _votes(BuildContext context) => Watch(() {
    final review = state.review.value;
    final busy = state.busy.value;
    final total = review.ratingAmount ?? 0;
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getString.reviewHelpfulQuestion,
                  style: context.textTheme.titleSmall,
                ),
                if (total > 0)
                  Text(
                    getString.reviewHelpful(review.rating ?? 0, total),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton.filledTonal(
            isSelected: review.vote == ReviewVote.up,
            icon: const Icon(Icons.thumb_up_outlined),
            selectedIcon: const Icon(Icons.thumb_up_rounded),
            onPressed: busy ? null : () => state.vote(ReviewVote.up),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            isSelected: review.vote == ReviewVote.down,
            icon: const Icon(Icons.thumb_down_outlined),
            selectedIcon: const Icon(Icons.thumb_down_rounded),
            onPressed: busy ? null : () => state.vote(ReviewVote.down),
          ),
        ],
      ),
    );
  });
}
