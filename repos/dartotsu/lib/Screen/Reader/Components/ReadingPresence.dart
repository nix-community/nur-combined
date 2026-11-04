import 'package:flutter/widgets.dart';

import '../../../Api/Discord/DiscordPresence.dart';
import '../../../Api/Discord/PresenceScope.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';

class ReadingPresence extends StatelessWidget {
  final Media media;
  final String Function() number;
  final int since;
  final Widget child;

  const ReadingPresence({
    super.key,
    required this.media,
    required this.number,
    required this.since,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Watch(
    () => PresenceScope(
      presence: DiscordPresence.reading(
        media,
        number: number(),
        total: media.totalUnits,
        since: since,
      ),
      child: child,
    ),
  );
}
