import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaService.dart';
import '../../Widgets/Components/ScreenState.dart';

class InboxState extends ScreenState {
  final MediaService service;

  InboxState(this.service);

  late final tabs = TabController(
    length: 2,
    vsync: vsync,
    animationDuration: animDuration(300),
  );

  String? get currentUserId => service.socialView!.currentUserId;

  DiscordPresence get presence => DiscordPresence.browsing('Reading messages');

  @override
  void onClose() => tabs.dispose();
}
