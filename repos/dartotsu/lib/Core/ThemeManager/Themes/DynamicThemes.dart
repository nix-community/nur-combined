import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

ThemeData getCustomLightTheme(int color) {
  var theme = ColorScheme.fromSeed(
    seedColor: Color(color),
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: theme.primary,
    colorScheme: theme,
    appBarTheme: AppBarTheme(
      color: theme.primary,
      iconTheme: IconThemeData(color: theme.onPrimary),
    ),
    scaffoldBackgroundColor: theme.surface,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: theme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: theme.onSurface),
    ),
    fontFamily: 'Manrope',
  );
}

ThemeData getCustomDarkTheme(int color) {
  var theme = ColorScheme.fromSeed(
    seedColor: Color(color),
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: theme.primary,
    colorScheme: theme,
    appBarTheme: AppBarTheme(
      color: theme.primary,
      iconTheme: IconThemeData(color: theme.onPrimary),
    ),
    scaffoldBackgroundColor: theme.surface,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: theme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: theme.onSurface),
    ),
    fontFamily: 'Manrope',
  );
}

Future<ColorScheme> getImageMainColor(
  String imageUrl,
  Brightness brightness,
) async {
  return await ColorScheme.fromImageProvider(
    provider: ResizeImage(
      CachedNetworkImageProvider(imageUrl),
      width: 112,
      policy: ResizeImagePolicy.fit,
    ),
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
}
