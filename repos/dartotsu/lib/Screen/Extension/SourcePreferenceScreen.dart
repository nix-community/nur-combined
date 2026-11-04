import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Model/Setting.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../Settings/SettingsListView.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SourcePreferenceState.dart';

class SourcePreferenceScreen extends StatefulWidget {
  final Source source;

  const SourcePreferenceScreen({super.key, required this.source});

  @override
  State<SourcePreferenceScreen> createState() => _SourcePreferenceScreenState();
}

class _SourcePreferenceScreenState extends BaseScreen<SourcePreferenceScreen>
    with ScreenStateHost<SourcePreferenceScreen, SourcePreferenceState> {
  @override
  SourcePreferenceState buildState() => SourcePreferenceState(widget.source);

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Watch(() {
        final prefs = state.prefs.value;
        if (prefs == null) {
          return Skeletonizer(
            child: SettingsListView(
              title: widget.source.name,
              searchable: (_) => [
                for (var i = 0; i < 6; i++)
                  const Setting.normal(
                    name: 'Loading setting',
                    description: 'Loading description for this setting',
                  ),
              ],
            ),
          );
        }
        if (prefs.isEmpty) {
          return EmptyState(
            icon: Icons.tune_rounded,
            title: getString.noSourceSettings,
          );
        }
        return SettingsListView(
          title: widget.source.name,
          searchable: (ctx) => [for (final p in prefs) state.setting(ctx, p)],
        );
      }),
    );
  }
}
