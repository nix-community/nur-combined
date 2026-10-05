sed -i -e 's/fun Bitmap\.extractThemeColor(): Color {.*}/fun Bitmap.extractThemeColor(): Color { return DefaultThemeColor }/s' app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Theme.kt
# Actually, sed multiline is hard. I'll just write a python script in prePatch!
