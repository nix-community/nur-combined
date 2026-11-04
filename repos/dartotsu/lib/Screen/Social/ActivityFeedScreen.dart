import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Widgets/Components/BaseScreen.dart';
import 'Components/ActivityComposer.dart';
import 'Components/ActivityList.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ActivityFeedState.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';

class ActivityFeedScreen extends StatefulWidget {
  final MediaService service;
  final String? activityId;

  const ActivityFeedScreen({super.key, required this.service, this.activityId});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends BaseScreen<ActivityFeedScreen>
    with
        SingleTickerProviderStateMixin,
        ScreenStateHost<ActivityFeedScreen, ActivityFeedState> {
  @override
  ActivityFeedState buildState() =>
      ActivityFeedState(widget.service, widget.activityId);

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    final service = widget.service;
    if (state.single) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppScreenBar(title: getString.activity),
        body: ActivityList(
          service: service,
          scope: ActivityScope.single,
          activityId: widget.activityId,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(
        title: getString.activity,
        actions: [
          if (state.canMessage)
            IconButton(
              tooltip: getString.messages,
              icon: const Icon(Icons.mail_outline_rounded),
              onPressed: state.openMessages,
            ),
        ],
        bottom: state.hasGlobal
            ? AppTabs(
                controller: state.tabs,
                items: [
                  AppTabItem(getString.following),
                  AppTabItem(getString.global),
                ],
              )
            : null,
      ),
      body: TabBarView(
        controller: state.tabs,
        children: [
          ActivityList(
            service: service,
            scope: ActivityScope.following,
            composer: ComposerKind.activity,
            filterable: true,
          ),
          if (state.hasGlobal)
            ActivityList(service: service, scope: ActivityScope.global),
        ],
      ),
    );
  }
}
