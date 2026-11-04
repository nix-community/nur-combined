import 'package:flutter/material.dart';

import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import '../../Widgets/Components/ColorPickerView.dart';
import '../State/State.dart';
import 'LanguageSwitcher.dart';

Future<Color?> showColorPickerDialog(
  BuildContext context,
  Color initialColor, {
  bool showTransparent = true,
}) {
  var selectedColor = initialColor;
  final dialogContext = appOverlayContext ?? context;

  return AlertDialogBuilder(dialogContext)
      .popOnFinish(false)
      .setTitle(getString.pickColor)
      .setCustomView(
        SingleChildScrollView(
          child: ColorPickerView(
            initial: initialColor,
            onChanged: (color) => selectedColor = color,
          ),
        ),
      )
      .setNeutralButton(
        showTransparent ? getString.colorPickerTransparent : null,
        showTransparent
            ? () => popPage(dialogContext, Colors.transparent)
            : null,
      )
      .setNegativeButton(getString.cancel, () => popPage(dialogContext))
      .setPositiveButton(
        getString.ok,
        () => popPage(dialogContext, selectedColor),
      )
      .show<Color>();
}
