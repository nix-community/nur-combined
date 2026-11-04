import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/widgets.dart';

import '../../Core/State/State.dart';
import '../../Model/Setting.dart';
import '../../Widgets/Components/ScreenState.dart';

class ExtensionSourceSettingsState extends ScreenState {
  final Extension extension;
  final _changed = Trigger();

  ExtensionSourceSettingsState(this.extension);

  String get title => extension.name;

  void _then(void Function() action) {
    action();
    _changed.fire();
  }

  List<Setting> settings(BuildContext context) {
    _changed.track();
    return [
      for (final s in extension.settings(context))
        Setting(
          type: SettingType.values.firstWhere((t) => t.name == s.type.name),
          name: s.name,
          description: s.description,
          icon: s.icon,
          iconWidget: s.iconWidget,
          isVisible: s.isVisible,
          isActivity: s.isActivity,
          isChecked: s.isChecked,
          trailingIcon: s.trailingIcon,
          onClick: s.onClick == null ? null : () => _then(() => s.onClick!()),
          onLongClick: s.onLongClick == null
              ? null
              : () => _then(() => s.onLongClick!()),
          onSwitchChange: s.onSwitchChange == null
              ? null
              : (v) => _then(() => s.onSwitchChange!(v)),
          attach: s.attach,
          minValue: s.minValue,
          maxValue: s.maxValue,
          initialValue: s.initialValue,
          onSliderChange: s.onSliderChange == null
              ? null
              : (v) => _then(() => s.onSliderChange!(v)),
          onInputChange: s.onInputChange == null
              ? null
              : (v) => _then(() => s.onInputChange!(v)),
        ),
    ];
  }
}
