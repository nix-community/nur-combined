import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';

import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Nav/DpadNav.dart';
import 'ThemedContainer.dart';
import '../../Core/State/State.dart';
import '../../Utils/Nav/DpadLayers.dart';

double tabAmount(TabController controller, int index, [double? position]) {
  if (controller.indexIsChanging) return index == controller.index ? 1 : 0;
  final at =
      position ?? controller.animation?.value ?? controller.index.toDouble();
  return (1 - (at - index).abs()).clamp(0.0, 1.0).toDouble();
}

class AppTab extends StatelessWidget {
  final String label;
  final int? count;
  final Widget Function(Color color)? icon;
  final bool selected;
  final bool focused;
  final double? amount;

  const AppTab({
    super.key,
    required this.label,
    required this.selected,
    this.count,
    this.icon,
    this.focused = false,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final fill = amount ?? (selected ? 1.0 : 0.0);
    final on = fill >= 0.5;
    final color = Color.lerp(scheme.onSurfaceVariant, scheme.primary, fill)!;

    return AnimatedContainer(
      duration: animDuration(200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ThemedContainer(
        color: focused
            ? scheme.secondaryContainer
            : on
            ? scheme.surfaceContainerHigh
            : null,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!(color), const SizedBox(width: 8)],
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                color: color,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: animDuration(200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: on
                      ? scheme.primary.withValues(alpha: 0.15)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$count',
                  style: context.textTheme.labelMedium?.copyWith(color: color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;
  final void Function(bool focused, int index)? onFocusChange;
  final double inset;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onFocusChange,
    this.inset = 16,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final shown = [...tabs];
    if (shown.isNotEmpty) {
      shown[0] = Padding(
        padding: EdgeInsetsDirectional.only(start: inset),
        child: shown[0],
      );
    }
    return TabBar(
      controller: controller,
      isScrollable: true,
      dividerColor: Colors.transparent,
      tabAlignment: TabAlignment.start,
      indicator: const BoxDecoration(),
      indicatorPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onFocusChange: onFocusChange,
      tabs: shown,
    );
  }
}

class AppTabItem {
  final String label;
  final int? count;
  final Widget Function(Color color)? icon;

  const AppTabItem(this.label, {this.count, this.icon});
}

class AppTabs extends StatefulWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<AppTabItem> items;

  const AppTabs({super.key, required this.controller, required this.items});

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight + 8);

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  final _focused = Live<int?>(null);

  void _onFocus(bool focused, int index) {
    final next = focused
        ? index
        : (_focused.value == index ? null : _focused.value);
    if (next != _focused.value) _focused.value = next;
  }

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final controller = widget.controller;
    return DpadRow(
      child: AnimatedBuilder(
        animation: Listenable.merge([controller, controller.animation]),
        builder: (_, _) => AppTabBar(
          controller: widget.controller,
          onFocusChange: _onFocus,
          tabs: [
            for (final (i, item) in widget.items.indexed)
              AppTab(
                label: item.label,
                count: item.count,
                icon: item.icon,
                selected: tabAmount(controller, i) >= 0.5,
                amount: tabAmount(controller, i),
                focused: kFocused(_focused.value == i),
              ),
          ],
        ),
      ),
    );
  }
}
