import 'package:flutter/material.dart';

ThemeData materialThemeLight(ColorScheme theme) {
  return ThemeData(
    primaryColor: theme.primary,
    colorScheme: theme,
    fontFamily: 'Manrope',
  );
}

ThemeData materialThemeDark(ColorScheme theme) {
  return ThemeData(
    primaryColor: theme.primary,
    colorScheme: theme,
    scaffoldBackgroundColor: theme.surface,
    fontFamily: 'Manrope',
  );
}
