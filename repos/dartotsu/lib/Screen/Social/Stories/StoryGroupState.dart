import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/ScreenState.dart';
import 'StorySeen.dart';

class StoryGroupState extends ScreenState {
  final MediaService service;
  final StoryGroup group;
  final Live<bool> hold;
  final VoidCallback onFinished;
  final VoidCallback onBack;
  bool active;

  StoryGroupState({
    required this.service,
    required this.group,
    required this.hold,
    required this.onFinished,
    required this.onBack,
    required this.active,
  });

  static const duration = Duration(seconds: 7);

  late final AnimationController timer = AnimationController(
    vsync: vsync,
    duration: duration,
  )..addStatusListener(onStatus);
  final index = 0.live;
  final forward = true.live;
  int holds = 0;

  SocialScreenView get view => service.socialView!;
  List<Activity> get items => group.activities;
  Activity get story => items[index.value];

  @override
  void onInit() {
    final seen = StorySeen.read(service);
    final first = items.indexWhere((a) => !seen.contains(a.id));
    index.value = first < 0 ? 0 : first;
    holdSub = onChange(hold, (_) => onSwipeHold());
    if (active) start();
  }

  final version = Trigger();
  Disposer? holdSub;
  bool swipeHeld = false;

  void onSwipeHold() {
    final want = hold.value;
    if (want == swipeHeld) return;
    swipeHeld = want;
    want ? holdNow() : release();
  }

  void activeChanged(bool was, bool now) {
    active = now;
    if (now && !was) {
      start();
    } else if (!now && was) {
      timer.stop();
    }
  }

  @override
  void onClose() {
    holdSub?.dispose();
    _heartTimer?.cancel();
    timer.dispose();
  }

  void start() {
    StorySeen.mark(service, story.id);
    timer
      ..stop()
      ..value = 0;
    if (holds == 0) unawaited(timer.forward());
  }

  void onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && active) next();
  }

  void holdNow() {
    holds++;
    timer.stop();
  }

  void release() {
    if (holds > 0) holds--;
    if (holds == 0 && mounted && active && !timer.isCompleted) {
      unawaited(timer.forward());
    }
  }

  void next() {
    if (!mounted) return;
    if (index.value < items.length - 1) {
      forward.value = true;
      index.value++;
      start();
    } else {
      onFinished();
    }
  }

  void previous() {
    if (index.value > 0) {
      forward.value = false;
      index.value--;
      start();
    } else {
      onBack();
      start();
    }
  }

  bool heart = false;
  Timer? _heartTimer;

  void doubleTapLike() {
    if (!story.isLiked) unawaited(like());
    if (!view.canInteract) return;
    heart = true;
    version.fire();
    _heartTimer?.cancel();
    _heartTimer = Timer(const Duration(milliseconds: 750), () {
      heart = false;
      if (mounted) version.fire();
    });
  }

  Future<void> like() async {
    if (!view.canInteract) return snackString(getString.logInToLike);
    final a = story;
    final was = a.isLiked;
    a.isLiked = !was;
    a.likeCount += was ? -1 : 1;
    version.fire();
    unawaited(HapticFeedback.selectionClick());
    final ok = await view.toggleLike(a.id);
    if (!ok && mounted) {
      a.isLiked = was;
      a.likeCount += was ? 1 : -1;
      version.fire();
      snackString(getString.failedToLike);
    }
  }

  Future<T?> paused<T>(Future<T> Function() action) async {
    holdNow();
    try {
      return await action();
    } finally {
      if (mounted) {
        version.fire();
        release();
      }
    }
  }

  bool keyHeld = false;

  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !node.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        previous();
      case LogicalKeyboardKey.arrowRight:
        next();
      case LogicalKeyboardKey.arrowDown:
        node.nextFocus();
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.space:
        keyHeld = !keyHeld;
        keyHeld ? holdNow() : release();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }
}
