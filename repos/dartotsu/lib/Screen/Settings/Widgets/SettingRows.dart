import 'package:flutter/material.dart';

import '../../../Core/Fonts/AppFonts.dart';
import '../../../Core/ThemeManager/CustomColorPicker.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Model/Setting.dart';
import '../../../Widgets/Components/ChoiceSheet.dart';
import '../../../Widgets/Components/FontSheet.dart';

Setting choiceSetting<T>(
  BuildContext context, {
  required String name,
  required IconData icon,
  required T value,
  required List<T> values,
  required String Function(T) label,
  required ValueChanged<T> onPick,
  bool isVisible = true,
}) => Setting.normal(
  name: name,
  description: label(value),
  icon: icon,
  isVisible: isVisible,
  isActivity: true,
  onClick: () async {
    final picked = await showChoiceSheet<T>(
      context,
      title: name,
      icon: icon,
      selected: value,
      options: [for (final v in values) ChoiceOption(v, label(v))],
    );
    if (picked != null) onPick(picked);
  },
);

Setting switchSetting(
  String name,
  String desc,
  IconData icon,
  bool value,
  ValueChanged<bool> onChange,
) => Setting.switchType(
  name: name,
  description: desc,
  icon: icon,
  isChecked: value,
  onSwitchChange: onChange,
);

Setting sliderSetting(
  String name,
  String desc,
  IconData icon,
  int value,
  int min,
  int max,
  ValueChanged<int> onChange,
) => Setting.slider(
  name: name,
  description: desc,
  icon: icon,
  minValue: min,
  maxValue: max,
  initialValue: value.clamp(min, max),
  onSliderChange: onChange,
);

Setting fontSetting(
  BuildContext context, {
  required String name,
  required String value,
  required ValueChanged<String> onPick,
}) => Setting.normal(
  name: name,
  description: fontLabel(value, getString.fontAppDefault),
  icon: Icons.font_download_rounded,
  isActivity: true,
  onClick: () async {
    final picked = await showFontSheet(context, title: name, selected: value);
    if (picked != null) onPick(picked);
  },
);

Setting colorSetting(
  BuildContext context,
  String name,
  IconData icon,
  int value,
  ValueChanged<int> onPick,
) => Setting.normal(
  name: name,
  icon: icon,
  trailing: Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: Color(value),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white54),
    ),
  ),
  onClick: () async {
    final picked = await showColorPickerDialog(context, Color(value));
    if (picked != null) onPick(picked.toARGB32());
  },
);
