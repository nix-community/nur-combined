import '../../../Logger.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/ScreenState.dart';
import 'ActivityComposer.dart';

class RepliesState extends ScreenState {
  final MediaService service;
  final Activity activity;

  RepliesState({required this.service, required this.activity});

  SocialScreenView get view => service.socialView!;
  final replies = Live<List<ActivityReply>?>(null);
  final failed = false.live;

  @override
  void onInit() => unawaited(load());

  final version = Trigger();
  int page = 1;
  final hasNext = false.live;
  final loadingMore = false.live;

  Future<void> load() async {
    try {
      final result = await view.replies(activity.id);
      if (!mounted) return;
      replies.value = [...result.items];
      hasNext.value = result.hasNext;
      page = 2;
      failed.value = false;
      activity.replyCount = replies.value!.length;
    } catch (e, st) {
      logError('RepliesState', e, st);
      if (mounted) failed.value = true;
    }
  }

  Future<void> more() async {
    if (loadingMore.value || !hasNext.value || replies.value == null) return;
    loadingMore.value = true;
    try {
      final result = await view.replies(activity.id, page: page);
      if (!mounted) return;
      final known = {for (final r in replies.value!) r.id};
      replies.value!.addAll(result.items.where((r) => !known.contains(r.id)));
      replies.refresh();
      hasNext.value = result.hasNext;
      page++;
      activity.replyCount = replies.value!.length;
    } catch (e, st) {
      logError('RepliesState', e, st);
      if (mounted) hasNext.value = false;
    } finally {
      if (mounted) loadingMore.value = false;
    }
  }

  bool onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical && n.metrics.extentAfter < 400) {
      unawaited(more());
    }
    return false;
  }

  Future<void> compose({ActivityReply? replyTo, ActivityReply? edit}) async {
    final done = await showActivityComposer(
      context,
      view,
      kind: ComposerKind.reply,
      activityId: activity.id,
      editId: edit?.id,
      initial: edit?.text ?? (replyTo == null ? '' : '@${replyTo.user.name} '),
    );
    if (done) await load();
  }

  Future<void> delete(ActivityReply reply) async {
    final ok = await view.deleteReply(reply.id);
    if (!mounted) return;
    if (!ok) return snackString(getString.failedToDelete);
    replies.value?.remove(reply);
    replies.refresh();
    activity.replyCount = replies.value?.length ?? 0;
  }

  Future<void> like(ActivityReply reply) async {
    final was = reply.isLiked;
    reply.isLiked = !was;
    reply.likeCount += was ? -1 : 1;
    version.fire();
    unawaited(HapticFeedback.selectionClick());
    final ok = await view.toggleLike(reply.id, reply: true);
    if (!ok && mounted) {
      reply.isLiked = was;
      reply.likeCount += was ? 1 : -1;
      version.fire();
      snackString(getString.failedToLike);
    }
  }
}
