import 'dart:async';

import '../../Api/Services/MangaBaka/Auth.dart';
import '../../Api/Services/MangaBaka/Client.dart';
import '../../Api/Services/MangaBaka/Community.dart';
import '../../Api/Services/MangaBaka/Data/Community.dart';
import '../../Core/State/State.dart';
import '../../Logger.dart';
import '../../Widgets/Components/ScreenState.dart';

class StacksState extends ScreenState {
  final String? owner;

  StacksState({this.owner});

  MangaBakaCommunity get _api => mangaBakaAuth.community;

  bool get signedIn => mangaBakaAuth.isLoggedIn;

  late final scope = StackScope.all.live;
  final items = <MangaBakaStack>[].liveList;
  final loading = false.live;
  final failed = false.live;
  final first = true.live;
  final needsScope = false.live;
  final hasNext = true.live;
  int _page = 1;
  int _run = 0;

  List<StackScope> get scopes => owner != null
      ? const []
      : [
          StackScope.all,
          StackScope.featured,
          if (signedIn) ...[
            StackScope.mine,
            StackScope.saved,
            StackScope.following,
          ],
        ];

  @override
  void onInit() => unawaited(load(reset: true));

  Future<void> signInAgain() async {
    if (await mangaBakaAuth.login()) await load(reset: true);
  }

  void setScope(StackScope next) {
    if (next == scope.value) return;
    scope.value = next;
    unawaited(load(reset: true));
  }

  Future<void> load({bool reset = false}) async {
    if (reset) {
      _run++;
      items.clear();
      _page = 1;
      hasNext.value = true;
      failed.value = false;
      needsScope.value = false;
      first.value = true;
      loading.value = false;
    }
    if (loading.value || !hasNext.value) return;
    final run = _run;
    loading.value = true;
    try {
      final page = owner != null
          ? await _api.userStacks(owner!, page: _page)
          : await _api.stacks(scope.value, page: _page);
      if (run != _run) return;
      final known = {for (final s in items) s.id};
      items.addAll(page.items.where((s) => !known.contains(s.id)));
      hasNext.value = page.hasNext;
      if (page.hasNext) _page++;
      failed.value = false;
    } on MangaBakaException catch (e, st) {
      if (e.status != 403) logError('StacksState', e, st);
      if (run == _run) {
        if (e.status == 403) {
          needsScope.value = true;
          hasNext.value = false;
        } else {
          failed.value = true;
        }
      }
    } catch (e, st) {
      logError('StacksState', e, st);
      if (run == _run) failed.value = true;
    } finally {
      if (run == _run) {
        loading.value = false;
        first.value = false;
      }
    }
  }
}
