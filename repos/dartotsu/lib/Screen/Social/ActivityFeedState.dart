import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaService.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SocialNavigation.dart';

class ActivityFeedState extends ScreenState {
  final MediaService service;
  final String? activityId;

  ActivityFeedState(this.service, this.activityId);

  late final bool hasGlobal = service.socialView!.hasGlobalFeed;
  late final tabs = TabController(
    length: hasGlobal ? 2 : 1,
    vsync: vsync,
    animationDuration: animDuration(300),
  );

  bool get single => activityId != null;

  bool get canMessage => service.socialView!.currentUserId != null;

  DiscordPresence get presence =>
      DiscordPresence.browsing('Reading the activity feed');

  void openMessages() => openInbox(context, service);

  @override
  void onClose() => tabs.dispose();
}
