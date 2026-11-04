import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Core/Services/Api/IsbnLookup.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Widgets/Components/ScreenState.dart';

class BarcodeState extends ScreenState {
  final isbn = TextEditingController();
  final busy = false.live;
  final error = Live<String?>(null);

  static bool get cameraSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  @override
  void onClose() => isbn.dispose();

  Future<void> submit([String? code]) async {
    if (busy.value) return;
    final raw = (code ?? isbn.text).trim();
    if (normalizeIsbn(raw) == null) {
      error.value = getString.barcodeInvalid;
      return;
    }
    busy.value = true;
    error.value = null;
    final title = await IsbnLookup.title(raw);
    if (!context.mounted) return;
    busy.value = false;
    if (title == null) {
      error.value = getString.barcodeNotFound(raw);
      return;
    }
    popPage(context, title);
  }
}
