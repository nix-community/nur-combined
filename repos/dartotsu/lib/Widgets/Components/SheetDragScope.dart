import 'package:flutter/material.dart';

import '../../Utils/Animation/WidgetAnimations.dart';
import 'ScrollConfig.dart';

class SheetDragScope extends StatefulWidget {
  final Widget child;

  const SheetDragScope({super.key, required this.child});

  @override
  State<SheetDragScope> createState() => _SheetDragScopeState();
}

class _SheetDragScopeState extends State<SheetDragScope> {
  double _dy = 0;
  bool _dragging = false;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is OverscrollNotification &&
        n.dragDetails != null &&
        n.overscroll < 0) {
      _dragging = true;
      setState(() => _dy = (_dy - n.overscroll).clamp(0, double.infinity));
    } else if (n is ScrollUpdateNotification &&
        _dy > 0 &&
        n.dragDetails != null &&
        (n.scrollDelta ?? 0) > 0) {
      setState(() => _dy = (_dy - n.scrollDelta!).clamp(0, double.infinity));
    } else if (n is ScrollEndNotification && _dy > 0) {
      final velocity = n.dragDetails?.primaryVelocity ?? 0;
      _dragging = false;
      if (_dy > 120 || velocity > 700) {
        Navigator.of(context).maybePop();
      }
      setState(() => _dy = 0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: AnimatedContainer(
          duration: _dragging ? Duration.zero : animDuration(200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _dy, 0),
          child: ScrollConfig(
            context,
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: widget.child,
          ),
        ),
      );
}
