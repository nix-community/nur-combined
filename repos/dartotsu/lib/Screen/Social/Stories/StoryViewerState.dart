import '../../../Utils/Animation/WidgetAnimations.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Core/State/State.dart';
import '../../../Widgets/Components/ScreenState.dart';

class StoryViewerState extends ScreenState {
  final int initialGroup;
  final int groupCount;

  StoryViewerState({required this.initialGroup, required this.groupCount});

  late final PageController pages = PageController(initialPage: initialGroup);
  late final current = initialGroup.live;
  final drag = 0.0.live;
  final dragging = false.live;
  final hold = false.live;

  @override
  void onInit() {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
  }

  @override
  void onClose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    pages.dispose();
  }

  void close() => Navigator.of(context).maybePop();

  void goTo(int index) {
    if (index < 0 || index >= groupCount) {
      if (index >= groupCount) close();
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    unawaited(
      pages.animateToPage(
        index,
        duration: animDuration(420),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
