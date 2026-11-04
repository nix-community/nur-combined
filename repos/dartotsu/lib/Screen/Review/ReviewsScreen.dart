import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/Services/Model/User.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import 'ReviewCard.dart';
import 'ReviewScreen.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ReviewsState.dart';

class ReviewsScreen extends StatefulWidget {
  final Media media;
  final DetailScreenView view;
  final List<Review> initial;

  const ReviewsScreen({
    super.key,
    required this.media,
    required this.view,
    this.initial = const [],
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends BaseScreen<ReviewsScreen>
    with ScreenStateHost<ReviewsScreen, ReviewsState> {
  @override
  ReviewsState buildState() => ReviewsState(
    media: widget.media,
    view: widget.view,
    initial: widget.initial,
  );

  @override
  Widget buildContent(BuildContext context) {
    final service = state.service;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(title: getString.reviewsTitle),
      body: Watch(() {
        final loading = state.loadingMore.value;
        if (state.items.isEmpty) {
          return loading
              ? Skeletonizer(
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(Dimens.gap),
                    children: [
                      for (var i = 0; i < 4; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: Dimens.gapSm),
                          child: ReviewCard(
                            review: Review(
                              id: 0,
                              mediaId: 0,
                              mediaType: 'ANIME',
                              summary: 'Loading review summary',
                              body:
                                  'Loading the review text so the placeholder has some body to show.',
                              score: 80,
                              rating: 10,
                              ratingAmount: 12,
                              user: User(id: 0, name: 'Loading user'),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: state.failed.value
                      ? getString.reviewsFailed
                      : getString.reviewsEmpty,
                  failed: state.failed.value,
                );
        }
        final items = state.items.toList();
        return NotificationListener<ScrollNotification>(
          onNotification: state.onScroll,
          child: ScrollConfig(
            context,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Dimens.gap,
                Dimens.gapXs,
                Dimens.gap,
                Dimens.gapXl,
              ),
              itemCount: items.length + (loading ? 1 : 0),
              separatorBuilder: (_, _) => SizedBox(height: Dimens.gapSm),
              itemBuilder: (_, i) => i == items.length
                  ? Padding(
                      padding: EdgeInsets.all(Dimens.gapLg),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : _animated(
                      ReviewCard(
                        review: items[i],
                        onUserTap: () =>
                            openReviewer(context, service, items[i]),
                        onTap: () => navigateToPage(
                          context,
                          ReviewScreen(
                            review: items[i],
                            service: service,
                            view: widget.view,
                          ),
                        ),
                      ),
                      i,
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _animated(Widget card, int index) =>
      index < 10 ? card.animateStagger(index) : card;
}
