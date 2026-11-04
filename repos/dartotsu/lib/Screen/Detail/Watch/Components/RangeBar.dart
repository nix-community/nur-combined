import 'package:flutter/material.dart';

import '../../../../Utils/Animation/WidgetAnimations.dart';
import '../../../../Utils/Extensions/ClickCursor.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Utils/Nav/DpadNav.dart';

class RangeBar extends StatefulWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const RangeBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<RangeBar> createState() => _RangeBarState();
}

class _RangeBarState extends State<RangeBar> {
  final _scroll = ScrollController();
  final _keys = <int, GlobalKey>{};

  GlobalKey _key(int i) => _keys.putIfAbsent(i, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _reveal(animate: false);
  }

  @override
  void didUpdateWidget(RangeBar old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _reveal();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reveal({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[widget.selected]?.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: animate ? animDuration(220) : Duration.zero,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: _scroll,
    scrollDirection: Axis.horizontal,
    child: DpadRegion(
      horizontalEdge: DpadEdgeBehavior.stop,
      child: Row(
        children: [
          for (final (i, label) in widget.labels.indexed)
            Padding(
              key: _key(i),
              padding: EdgeInsetsDirectional.only(end: Dimens.gapSm),
              child: ChoiceChip(
                mouseCursor: kClickCursor,
                label: Text(label),
                selected: i == widget.selected,
                showCheckmark: false,
                onSelected: (_) => widget.onChanged(i),
              ),
            ),
        ],
      ),
    ),
  );
}
