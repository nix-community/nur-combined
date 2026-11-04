String anilistSafeText(String text) {
  if (!text.runes.any((r) => r > 0xFFFF)) return text;
  final out = StringBuffer();
  for (final rune in text.runes) {
    if (rune > 0xFFFF) {
      out.write('&#$rune;');
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}
