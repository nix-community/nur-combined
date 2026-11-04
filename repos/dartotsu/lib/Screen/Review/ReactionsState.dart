import '../../Logger.dart';
import 'dart:async';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/ScreenState.dart';

class ReactionsState extends ScreenState {
  final Media media;
  final DetailScreenView view;

  ReactionsState({required this.media, required this.view});

  final items = <MediaReaction>[].liveList;
  final loading = true.live;
  final posting = false.live;

  bool get canReact => view.canReact;

  bool get hasMine => items.any((r) => r.mine);

  @override
  void onInit() => unawaited(load());

  Future<void> load() async {
    try {
      items.value = await view.reactions(media);
    } catch (e, st) {
      logError('ReactionsState', e, st);
    } finally {
      loading.value = false;
    }
  }

  Future<void> vote(MediaReaction reaction) async {
    if (!canReact) return;
    final was = reaction.voted;
    reaction
      ..voted = !was
      ..votes += was ? -1 : 1;
    items.refresh();
    final result = await view.voteReaction(
      MediaReaction(id: reaction.id, text: reaction.text, voted: was),
    );
    if (result == null || result == was) {
      reaction
        ..voted = was
        ..votes += was ? 1 : -1;
      items.refresh();
      snackString(getString.reactionsFailed);
    }
  }

  Future<bool> post(String text) async {
    if (posting.value) return false;
    posting.value = true;
    try {
      final made = await view.postReaction(media, text.trim());
      if (made == null) return false;
      items.value = [made, ...items];
      return true;
    } finally {
      posting.value = false;
    }
  }
}
