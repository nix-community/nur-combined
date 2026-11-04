import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/ScreenState.dart';

class ReviewState extends ScreenState {
  final Review initial;
  final MediaService service;
  final DetailScreenView? view;

  ReviewState({required this.initial, required this.service, this.view})
    : review = initial.live;

  final Live<Review> review;
  final busy = false.live;

  bool get canVote =>
      (view?.canRateReviews ?? false) && (service.auth?.isLoggedIn ?? false);

  Future<void> vote(ReviewVote tap) async {
    if (busy.value) return;
    final current = review.value;
    final target = current.vote == tap ? ReviewVote.none : tap;
    busy.value = true;
    try {
      final result = await view!.rateReview(current, target);
      if (result == null) {
        snackString(getString.reviewVoteFailed);
        return;
      }
      current
        ..rating = result.rating
        ..ratingAmount = result.ratingAmount
        ..userRating = result.userRating;
      review.refresh();
    } finally {
      busy.value = false;
    }
  }
}
