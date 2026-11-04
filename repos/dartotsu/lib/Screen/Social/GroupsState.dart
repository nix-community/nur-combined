import '../../Logger.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SocialNavigation.dart';

class GroupsState extends ScreenState {
  final MediaService service;

  GroupsState(this.service);

  SocialScreenView get view => service.socialView!;

  final controller = TextEditingController();
  late final scope =
      (service.isLoggedIn ? GroupScope.joined : GroupScope.popular).live;
  final category = Live<String?>(null);
  final categories = <GroupCategory>[].liveList;
  final items = <SocialGroup>[].liveList;
  final loading = false.live;
  final failed = false.live;
  final first = true.live;
  final hasNext = true.live;
  int _page = 1;
  int _run = 0;
  Timer? _debounce;

  static final placeholder = SocialGroup(
    id: '0',
    name: 'Loading group name',
    category: 'Category',
    members: 12345,
    isMember: true,
  );

  @override
  void onInit() {
    unawaited(_loadCategories());
    unawaited(load(reset: true));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    controller.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      categories.assignAll(await view.groupCategories());
    } catch (e, st) {
      logError('GroupsState', e, st);
    }
  }

  void setScope(GroupScope next) {
    if (next == scope.value) return;
    scope.value = next;
    unawaited(load(reset: true));
  }

  void setCategory(String? id) {
    category.value = id;
    unawaited(load(reset: true));
  }

  void onTerm(String _) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => unawaited(load(reset: true)),
    );
  }

  Future<void> load({bool reset = false}) async {
    if (reset) {
      _run++;
      items.clear();
      _page = 1;
      hasNext.value = true;
      failed.value = false;
      first.value = true;
      loading.value = false;
    }
    if (loading.value || !hasNext.value) return;
    final run = _run;
    loading.value = true;
    try {
      final page = await view.groups(
        scope.value,
        query: controller.text,
        categoryId: scope.value == GroupScope.joined ? null : category.value,
        page: _page,
      );
      if (run != _run) return;
      final known = {for (final g in items) g.id};
      items.addAll(page.items.where((g) => !known.contains(g.id)));
      hasNext.value = page.hasNext;
      if (page.hasNext) _page++;
      failed.value = false;
    } catch (e, st) {
      logError('GroupsState', e, st);
      if (run == _run) failed.value = true;
    } finally {
      if (run == _run) {
        loading.value = false;
        first.value = false;
      }
    }
  }

  bool onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical &&
        n.metrics.extentAfter < 600 &&
        hasNext.value &&
        !loading.value &&
        !failed.value) {
      unawaited(load());
    }
    return false;
  }

  void open(SocialGroup group) =>
      openGroup(context, service, group.id, seed: group);
}
