import 'package:flutter/services.dart';

import 'SnackBar.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Logger.dart';

void copyToClipboard(String text, {String? message}) {
  Clipboard.setData(ClipboardData(text: text));
  logger("Copied to clipboard: $text");
  snackString(message ?? getString.copiedToClipboard, simple: true);
}
