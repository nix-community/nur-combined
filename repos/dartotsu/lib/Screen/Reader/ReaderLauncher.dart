import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import 'Engine/ReaderRequest.dart';
import '../../Core/State/State.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Widgets/Components/CustomBottomDialog.dart';
import 'Components/ReaderLoadSheet.dart';
import 'Novel/NovelScreen.dart';
import 'ReaderScreen.dart';

Future<void> openReader(ReaderRequest request, {BuildContext? context}) async {
  final target = context ?? appContext;
  if (target == null || request.units.isEmpty) return;
  if (request.novel) {
    await navigateToPage(target, NovelScreen(request: request));
    return;
  }
  final pages = await showCustomBottomDialog<List<PageUrl>>(
    target,
    ReaderLoadSheet(request: request),
  );
  if (pages == null || !target.mounted) return;
  await navigateToPage(target, ReaderScreen(request: request.withPages(pages)));
}
