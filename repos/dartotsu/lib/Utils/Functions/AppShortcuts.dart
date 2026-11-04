import 'package:flutter/services.dart';

import '../../Core/ThemeManager/ThemeController.dart';
import '../Nav/DpadLayers.dart';
import 'DesktopFullscreen.dart';
import 'SnackBar.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';

final _keyboardMode = false.live;

bool get usingKeyboard => _keyboardMode.value;

set usingKeyboard(bool value) {
  if (_keyboardMode.value != value) _keyboardMode.value = value;
}

bool appShortcuts(KeyEvent event) {
  usingKeyboard = true;
  if (event is! KeyDownEvent) return false;

  final isShift = HardwareKeyboard.instance.isShiftPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;

  Future<void> toggleFullscreen() => toggleDesktopFullscreen();

  switch (event.logicalKey) {
    case LogicalKeyboardKey.escape:
      return layerBack();

    case LogicalKeyboardKey.f11:
      toggleFullscreen();
      return true;

    case LogicalKeyboardKey.enter:
      if (isAlt) {
        toggleFullscreen();
        return true;
      }
      return false;
  }

  if (!isShift) return false;

  final theme = find<ThemeController>();
  switch (event.logicalKey) {
    case LogicalKeyboardKey.keyG:
      final v = !theme.useGlassMode.value;
      theme.setGlassEffect(v);
      snackString(
        v ? getString.glassEffectEnabled : getString.glassEffectDisabled,
      );
      return true;

    case LogicalKeyboardKey.keyM:
      final v = !theme.useMaterialYou.value;
      theme.setMaterialYou(v);
      snackString(
        v ? getString.materialYouEnabled : getString.materialYouDisabled,
      );
      return true;

    case LogicalKeyboardKey.keyD:
      theme.toggleDarkMode();
      snackString(
        theme.isDarkModeActive
            ? getString.darkModeEnabled
            : getString.darkModeDisabled,
      );
      return true;

    case LogicalKeyboardKey.keyO:
      final v = !theme.isOled.value;
      theme.setOled(v);
      snackString(v ? 'OLED mode enabled' : 'OLED mode disabled');
      return true;
  }

  return false;
}
