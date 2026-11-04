import 'package:flutter/widgets.dart';

import '../Api/Discord/DiscordPresence.dart';
import '../Core/Services/MediaServiceController.dart';
import '../Core/State/State.dart';
import '../Widgets/Components/ScreenState.dart';
import 'Feed/FeedTabs.dart';

class MainState extends ScreenState {
  final VoidCallback onPresenceChanged;

  MainState({required this.onPresenceChanged});

  MediaServiceController get services => find();

  late final tab = homeTabIndex(services.currentService.value).live;
  final built = <int>{};
  Disposer? _serviceSub;
  Disposer? _tabSub;

  DiscordPresence get presence {
    final tabs = feedTabsFor(services.currentService.value);
    final label = tabs[tab.value.clamp(0, tabs.length - 1)].label;
    return DiscordPresence.browsing(
      label.toLowerCase() == 'home'
          ? 'On the home screen'
          : 'Browsing ${label.toLowerCase()}',
    );
  }

  @override
  void onInit() {
    built.add(tab.value);
    _tabSub = onChange(tab, (_) => onPresenceChanged());
    _serviceSub = onChange(services.currentService, (_) {
      final home = homeTabIndex(services.currentService.value);
      built
        ..clear()
        ..add(home);
      tab.value = home;
    });
  }

  @override
  void onClose() {
    _serviceSub?.dispose();
    _tabSub?.dispose();
  }

  void select(int index) {
    built.add(index);
    tab.value = index;
  }
}
