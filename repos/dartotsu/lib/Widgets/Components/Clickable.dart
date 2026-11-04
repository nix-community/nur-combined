import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';
import '../../Core/State/State.dart';
import '../../Utils/Nav/DpadNav.dart';

class Clickable extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool press;
  final HitTestBehavior behavior;

  const Clickable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.press = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  final _down = false.live;

  void _set(bool v) {
    if (widget.press && _down.value != v) _down.value = v;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final child = widget.press
        ? Watch(
            () => AnimatedScale(
              scale: _down.value ? 0.96 : 1,
              duration: animDuration(150),
              curve: Curves.easeOutCubic,
              child: widget.child,
            ),
          )
        : widget.child;
    final tappable = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        child: child,
      ),
    );
    if (!enabled) return tappable;
    return DpadFocusable(
      onSelect: widget.onTap,
      onLongSelect: widget.onLongPress,
      tapToSelect: false,
      builder: dpadScaleFocus,
      child: tappable,
    );
  }
}
