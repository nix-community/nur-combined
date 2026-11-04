import 'package:flutter/material.dart';

import '../Engine/ReaderItems.dart';
import '../Engine/ReaderSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';
import '../ReaderState.dart';
import 'OverscrollNext.dart';
import 'ReaderGapView.dart';
import 'ReaderImage.dart';
import 'ReaderZoom.dart';

class ReaderPagedView extends StatefulWidget {
  final ReaderState state;

  const ReaderPagedView({super.key, required this.state});

  @override
  State<ReaderPagedView> createState() => _ReaderPagedViewState();
}

class _ReaderPagedViewState extends State<ReaderPagedView> {
  late final PageController _controller;
  final _zoomed = false.live;

  ReaderState get state => widget.state;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: state.current.value);
    state.jumper = _jump;
  }

  @override
  void dispose() {
    if (state.jumper == _jump) state.jumper = null;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _jump(int index) async {
    if (!_controller.hasClients) return;
    if (state.settings.animate && (index - state.current.value).abs() <= 1) {
      await _controller.animateToPage(
        index,
        duration: animDuration(220),
        curve: Curves.easeOutCubic,
      );
    } else {
      _controller.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final settings = state.settings;
    final items = state.items.toList();
    final zoomed = _zoomed.value;
    state.settingsVersion.value;
    return OverscrollNext(
      state: state,
      child: PageView.builder(
        controller: _controller,
        reverse: settings.reversed,
        scrollDirection: settings.vertical ? Axis.vertical : Axis.horizontal,
        physics: zoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: items.length,
        onPageChanged: state.onVisible,
        itemBuilder: (context, i) => _page(context, items[i], settings),
      ),
    );
  }

  Widget _page(BuildContext context, ReaderItem item, ReaderSettings settings) {
    switch (item) {
      case ReaderGap gap:
        return ReaderGapView(state: state, gap: gap, fill: true);
      case ReaderSpread spread:
        final pair = [spread.first, spread.second];
        return Row(
          children: [
            for (final p in settings.reversed ? pair.reversed : pair)
              Expanded(
                child: ReaderImage(
                  key: ValueKey('${p.chapter}-${p.page}'),
                  page: p.url,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
          ],
        );
      case ReaderPage page:
        return ReaderZoom(
          key: ValueKey('${page.chapter}-${page.page}'),
          page: page.url,
          scale: settings.scale,
          doubleTap: settings.doubleTapZoom,
          onZoom: (z) => _zoomed.value = z,
        );
    }
  }
}
