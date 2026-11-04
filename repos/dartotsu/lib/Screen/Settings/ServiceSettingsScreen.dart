import 'package:flutter/material.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/LoadSvg.dart';
import 'Components/ServiceSettingsBody.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ServiceSettingsState.dart';

class ServiceSettingsScreen extends StatefulWidget {
  final MediaService initial;

  const ServiceSettingsScreen({super.key, required this.initial});

  @override
  State<ServiceSettingsScreen> createState() => _ServiceSettingsScreenState();
}

class _ServiceSettingsScreenState extends BaseScreen<ServiceSettingsScreen>
    with
        SingleTickerProviderStateMixin,
        ScreenStateHost<ServiceSettingsScreen, ServiceSettingsState> {
  @override
  ServiceSettingsState buildState() => ServiceSettingsState(widget.initial);

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(
        title: getString.settings,
        bottom: !state.hasTabs
            ? null
            : AppTabs(
                controller: state.tab,
                items: [
                  for (final service in state.services)
                    AppTabItem(
                      service.name,
                      icon: (color) => loadSvg(
                        service.iconPath,
                        width: 18,
                        height: 18,
                        color: color,
                      ),
                    ),
                ],
              ),
      ),
      body: TabBarView(
        controller: state.tab,
        children: [
          for (final service in state.services)
            ServiceSettingsBody(service: service),
        ],
      ),
    );
  }
}
