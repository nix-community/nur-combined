import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Core/State/State.dart';
import '../../Utils/Animation/WidgetAnimations.dart';

class SeekProgressBar extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double step;
  final Color? activeColor;
  final Color? trackColor;
  final double thickness;

  const SeekProgressBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 0.05,
    this.activeColor,
    this.trackColor,
    this.thickness = 5,
  });

  @override
  State<SeekProgressBar> createState() => _SeekProgressBarState();
}

class _SeekProgressBarState extends State<SeekProgressBar> {
  final pressed = false.live;

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  KeyEventResult _key(KeyEvent event, TextDirection direction) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final forward = direction == TextDirection.rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final back = direction == TextDirection.rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == forward) {
      widget.onChanged((widget.value + widget.step).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    if (key == back) {
      widget.onChanged((widget.value - widget.step).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = widget.activeColor ?? scheme.primary;
    final track = widget.trackColor ?? Colors.white.withValues(alpha: 0.28);
    final direction = Directionality.of(context);
    final down = pressed.value;
    final thick = down ? widget.thickness + 3 : widget.thickness;
    final knob = down ? 22.0 : 14.0;
    final value = widget.value.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        double at(double dx) {
          final f = (dx / width).clamp(0.0, 1.0);
          return direction == TextDirection.rtl ? 1 - f : f;
        }

        final left = (value * width - knob / 2).clamp(0.0, width - knob);
        return Focus(
          onKeyEvent: (node, event) => _key(event, direction),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              pressed.value = true;
              widget.onChanged(at(d.localPosition.dx));
            },
            onTapUp: (_) => pressed.value = false,
            onTapCancel: () => pressed.value = false,
            onHorizontalDragStart: (_) => pressed.value = true,
            onHorizontalDragUpdate: (d) =>
                widget.onChanged(at(d.localPosition.dx)),
            onHorizontalDragEnd: (_) => pressed.value = false,
            onHorizontalDragCancel: () => pressed.value = false,
            child: SizedBox(
              height: 36,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: animDuration(140),
                    curve: Curves.easeOutCubic,
                    height: thick,
                    decoration: BoxDecoration(
                      color: track,
                      borderRadius: BorderRadius.circular(thick),
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: (36 - thick) / 2,
                    width: value * width,
                    child: AnimatedContainer(
                      duration: animDuration(140),
                      curve: Curves.easeOutCubic,
                      height: thick,
                      decoration: BoxDecoration(
                        color: active,
                        borderRadius: BorderRadius.circular(thick),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: left,
                    top: (36 - knob) / 2,
                    child: AnimatedContainer(
                      duration: animDuration(140),
                      curve: Curves.easeOutCubic,
                      width: knob,
                      height: knob,
                      decoration: BoxDecoration(
                        color: active,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: active.withValues(alpha: down ? 0.35 : 0.0),
                            blurRadius: 0,
                            spreadRadius: down ? 5 : 0,
                          ),
                          const BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
