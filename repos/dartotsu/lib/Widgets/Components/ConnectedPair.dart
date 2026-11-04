import 'package:flutter/material.dart';

import '../../Core/ThemeManager/GlassTheme.dart';
import '../../Utils/Nav/DpadNav.dart';

class ConnectedPair extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final String? iconTooltip;
  final Color color;
  final Color? iconColor;
  final Color? iconBackground;
  final double height;

  const ConnectedPair({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.icon,
    this.onIconTap,
    this.iconTooltip,
    this.iconColor,
    this.iconBackground,
    this.height = 56,
  });

  static const _big = Radius.circular(28);
  static const _small = Radius.circular(6);

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    final main = BorderRadiusDirectional.horizontal(
      start: _big,
      end: hasIcon ? _small : _big,
    );
    const side = BorderRadiusDirectional.horizontal(start: _small, end: _big);
    final edge = GlassTheme.edgeOf(context) ?? BorderSide.none;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: color,
            shape: RoundedRectangleBorder(borderRadius: main, side: edge),
            clipBehavior: Clip.antiAlias,
            child: DpadTap(
              onTap: onTap,
              borderRadius: main,
              child: SizedBox(height: height, child: child),
            ),
          ),
        ),
        if (hasIcon) ...[
          const SizedBox(width: 2),
          Tooltip(
            message: iconTooltip ?? '',
            child: Material(
              color: iconBackground ?? color,
              shape: RoundedRectangleBorder(borderRadius: side, side: edge),
              clipBehavior: Clip.antiAlias,
              child: DpadTap(
                onTap: onIconTap,
                borderRadius: side,
                child: SizedBox(
                  width: 60,
                  height: height,
                  child: Icon(icon, color: iconColor),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
