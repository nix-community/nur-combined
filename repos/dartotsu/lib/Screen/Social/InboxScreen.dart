import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'Components/ActivityList.dart';
import 'InboxState.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';

class InboxScreen extends StatefulWidget {
  final MediaService service;

  const InboxScreen({super.key, required this.service});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends BaseScreen<InboxScreen>
    with
        SingleTickerProviderStateMixin,
        ScreenStateHost<InboxScreen, InboxState> {
  @override
  InboxState buildState() => InboxState(widget.service);

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    final me = state.currentUserId;
    if (me == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppScreenBar(title: getString.messages),
        body: EmptyState(
          icon: Icons.mail_outline_rounded,
          title: getString.logInToSeeMessages,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(
        title: getString.messages,
        bottom: AppTabs(
          controller: state.tabs,
          items: [AppTabItem(getString.received), AppTabItem(getString.sent)],
        ),
      ),
      body: TabBarView(
        controller: state.tabs,
        children: [
          ActivityList(
            service: widget.service,
            scope: ActivityScope.inbox,
            userId: me,
          ),
          ActivityList(
            service: widget.service,
            scope: ActivityScope.sent,
            userId: me,
          ),
        ],
      ),
    );
  }
}
