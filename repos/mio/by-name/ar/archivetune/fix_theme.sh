#!/usr/bin/env bash
python3 -c "
import re
with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Theme.kt', 'r') as f: c = f.read()
c = re.sub(r'MaterialExpressiveTheme\(\s*colorScheme = animatedColorScheme,\s*motionScheme = motionScheme,\s*typography = typography,\s*shapes = expressiveShapes,\s*content = content,\s*\)', r'androidx.compose.material3.MaterialTheme(\n            colorScheme = animatedColorScheme,\n            typography = typography,\n            content = content,\n        )', c, flags=re.MULTILINE)
c = re.sub(r'@OptIn\(ExperimentalMaterial3ExpressiveApi::class\)\s*private object DisabledMotionScheme : MotionScheme \{.*?\n\}\n', '', c, flags=re.DOTALL)
c = re.sub(r'dynamicColorScheme\(\s*seedColor = seedColor,\s*isDark = isDark,\s*contrastLevel = contrastLevel,\s*style = style,\s*\)', r'androidx.compose.material3.darkColorScheme()', c, flags=re.MULTILINE)
c = c.replace('LocalArchiveTuneFontFamily provides resolvedFontFamily,', 'LocalArchiveTuneFontFamily provides (resolvedFontFamily as androidx.compose.ui.text.font.SystemFontFamily),')
c = re.sub(r'fun Bitmap\.extractThemeColor\(\): Color \{.*?\n\}', 'fun Bitmap.extractThemeColor(): Color { return DefaultThemeColor }', c, flags=re.DOTALL)
c = re.sub(r'fun Bitmap\.extractGradientColors\(\): List<Color> \{.*?\n\}', 'fun Bitmap.extractGradientColors(): List<Color> { return listOf(androidx.compose.ui.graphics.Color(0xFF595959), androidx.compose.ui.graphics.Color(0xFF0D0D0D)) }', c, flags=re.DOTALL)
c = re.sub(r'fun extractWallpaperThemeColor\(context: Context\): Color\? \{.*?\n\}', 'fun extractWallpaperThemeColor(context: Context): Color? { return null }', c, flags=re.DOTALL)
with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Theme.kt', 'w') as f: f.write(c)

with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Type.kt', 'r') as f: c = f.read()
c = c.replace('val AppFontFamily = FontFamily(Font(R.font.poppins))', 'val AppFontFamily = androidx.compose.ui.text.font.FontFamily.Default as androidx.compose.ui.text.font.SystemFontFamily')
c = c.replace('val LyricsFontFamily = FontFamily(Font(R.font.sfprodisplaybold))', 'val LyricsFontFamily = androidx.compose.ui.text.font.FontFamily.Default as androidx.compose.ui.text.font.SystemFontFamily')
with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Type.kt', 'w') as f: f.write(c)
"
