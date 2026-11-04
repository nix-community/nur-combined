import 'dart:async';

import 'package:flutter/material.dart';

import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/AppSheet.dart';
import '../../Widgets/Components/CustomBottomDialog.dart';
import 'TogetherController.dart';
import 'TogetherLink.dart';
import 'TogetherRoomView.dart';

Future<void> showTogetherSheet(BuildContext context) {
  final session = find<TogetherController>();
  session.sheetOpen = true;
  session.unread.value = 0;
  return showCustomBottomDialog<void>(
    context,
    TogetherSheet(session: session),
  ).whenComplete(() => session.sheetOpen = false);
}

class TogetherSheet extends StatefulWidget {
  final TogetherController session;

  const TogetherSheet({super.key, required this.session});

  @override
  State<TogetherSheet> createState() => _TogetherSheetState();
}

class _TogetherSheetState extends State<TogetherSheet> {
  TogetherController get s => widget.session;

  final _link = TextEditingController();

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final joined = await joinRoomLink(_link.text);
    if (!joined) return snackString(getString.togetherBadLink, simple: true);
    if (mounted) popPage(context);
  }

  @override
  Widget build(BuildContext context) => AppSheet(
    title: getString.togetherTitle,
    heightFactor: s.active ? 0.88 : null,
    child: Watch(
      () => s.active && s.status.value != TogetherStatus.failed
          ? TogetherRoomView(session: s)
          : _join_(context),
    ),
  );

  Widget _join_(BuildContext context) {
    final scheme = context.colorScheme;
    final failed = s.status.value == TogetherStatus.failed;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimens.pagePad,
        Dimens.gapXs,
        Dimens.pagePad,
        Dimens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.groups_rounded,
                size: 30,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(height: Dimens.gap),
          Text(
            getString.togetherIntro,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: Dimens.gapLg),
          TextField(
            controller: _link,
            autofocus: true,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => unawaited(_join()),
            decoration: InputDecoration(
              labelText: getString.togetherRoomLink,
              prefixIcon: const Icon(Icons.link_rounded),
            ),
          ),
          if (failed && s.error.value != null) ...[
            SizedBox(height: Dimens.gap),
            Text(
              getString.togetherFailed(s.error.value!),
              style: context.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          SizedBox(height: Dimens.gapLg),
          FilledButton.icon(
            onPressed: s.status.value == TogetherStatus.connecting
                ? null
                : () => unawaited(_join()),
            icon: const Icon(Icons.login_rounded),
            label: Text(getString.togetherJoinRole),
          ),
        ],
      ),
    );
  }
}
