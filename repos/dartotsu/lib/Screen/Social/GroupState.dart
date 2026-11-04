import '../../Logger.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Function.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Utils/Nav/DpadNav.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import '../../Widgets/Components/ScreenState.dart';

class GroupState extends ScreenState {
  final MediaService service;
  final String idOrSlug;
  final SocialGroup? seed;

  GroupState({required this.service, required this.idOrSlug, this.seed});

  SocialScreenView get view => service.socialView!;

  late final group = Live<SocialGroup?>(seed);
  final failed = false.live;
  final busy = false.live;
  final version = Trigger();
  final tab = 0.live;
  final navLane = GlobalKey<DpadRegionState>();

  String get groupId => group.value?.id ?? idOrSlug;

  bool get canJoin => view.canInteract && group.value != null;

  @override
  void onInit() => unawaited(load());

  Future<void> load() async {
    failed.value = false;
    try {
      final found = await view.group(idOrSlug);
      if (found == null) {
        if (group.value == null) failed.value = true;
        return;
      }
      group.value = found;
      version.fire();
    } catch (e, st) {
      logError('GroupState', e, st);
      if (group.value == null) failed.value = true;
    }
  }

  void toggle() {
    final g = group.value;
    if (g == null || busy.value) return;
    if (g.isMember) {
      AlertDialogBuilder(context)
          .setTitle(getString.groupsLeave)
          .setMessage(getString.groupsLeaveAsk)
          .setPositiveButton(getString.groupsLeave, () => unawaited(_flip(g)))
          .setNegativeButton(getString.cancel, null)
          .show<void>()
          .ignore();
    } else {
      unawaited(_flip(g));
    }
  }

  Future<void> _flip(SocialGroup g) async {
    busy.value = true;
    final wasMember = g.isMember;
    final next = await view.toggleGroup(g);
    if (!mounted) return;
    busy.value = false;
    if (next == null) {
      snackString(
        wasMember ? getString.groupsLeaveFailed : getString.groupsJoinFailed,
      );
      return;
    }
    await load();
    if (mounted && group.value?.isMember != next) {
      group.value
        ?..isMember = next
        ..rank = next ? 'pleb' : null;
      version.fire();
    }
  }

  void openInBrowser() {
    final url = group.value?.siteUrl;
    if (url != null) unawaited(openLinkInBrowser(url));
  }
}
