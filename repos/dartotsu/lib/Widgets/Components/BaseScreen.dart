import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Api/Discord/PresenceScope.dart';
import '../../Core/ThemeManager/GlassBackgroundSource.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import 'BlurredImage.dart';
import 'GlassSurface.dart';
import 'ScrollTopButton.dart';
import '../../Core/State/State.dart';

abstract class BaseScreen<T extends StatefulWidget> extends State<T> {
  Widget buildContent(BuildContext context);

  DiscordPresence? get presence => null;

  final _presenceTick = Trigger();

  void refreshPresence() => _presenceTick.fire();

  String? get glassBackgroundUrl => resolveGlassBackground();

  bool get safeArea => true;

  @override
  Widget build(BuildContext context) {
    final theme = find<ThemeController>();
    final built = ScrollTopButton(child: Watch(() => buildContent(context)));
    final content = presence == null
        ? built
        : Watch(() {
            _presenceTick.track();
            return PresenceScope(presence: presence!, child: built);
          });

    return Watch(() {
      final glass = theme.useGlassMode.value;
      final stack = Stack(
        children: [
          if (glass) GlassBackground(imageUrl: glassBackgroundUrl),
          Scaffold(
            backgroundColor: glass ? Colors.transparent : null,
            body: safeArea ? SafeArea(child: content) : content,
          ),
        ],
      );
      return glass ? BackdropGroup(child: stack) : stack;
    });
  }
}

class GlassBackground extends StatelessWidget {
  final String? imageUrl;

  const GlassBackground({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Positioned.fill(
      child: GlassBackdrop(
        image: url == null
            ? null
            : BlurredImage(
                url: url,
                fallback: kFallbackGlassBackground,
                saturation: GlassStyle.backdropSaturation,
              ),
      ),
    );
  }
}
