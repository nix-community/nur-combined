import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/ServiceSwitcher.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/AlertDialogBuilder.dart';
import '../../Widgets/Components/ScreenState.dart';

String cleanToken(String raw) {
  final text = raw.trim();
  final match = RegExp(r'access_token=([^&\s]+)').firstMatch(text);
  return (match?.group(1) ?? text).replaceAll(RegExp(r'\s'), '');
}

void showTokenLogin(
  BuildContext context,
  ServiceAuth auth, {
  void Function(bool ok)? onResult,
}) {
  final controller = TextEditingController();
  final url = auth.tokenLoginUrl;
  if (url != null) {
    unawaited(launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication));
  }
  AlertDialogBuilder(context)
    ..setTitle(getString.loginWithToken)
    ..setOnDismissListener(controller.dispose)
    ..setCustomView(
      TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: getString.pasteTokenHint),
      ),
    )
    ..setPositiveButton(getString.login, () async {
      final token = cleanToken(controller.text);
      if (token.isEmpty) {
        snackString(getString.pasteTokenHint);
        return;
      }
      final ok = await auth.loginWithToken(token);
      if (ok) snackString(getString.loggedIn);
      onResult?.call(ok);
    })
    ..setNegativeButton(getString.cancel, null)
    ..show();
}

class LoginViewState extends ScreenState {
  final VoidCallback? onDone;
  final bool embedded;

  LoginViewState({this.onDone, this.embedded = false});

  final busy = false.live;

  MediaServiceController get services => find();

  bool get guest => !embedded;

  Future<void> run(Future<bool> Function() action) async {
    busy.value = true;
    try {
      final ok = await action();
      if (ok && mounted) onDone?.call();
    } finally {
      busy.value = false;
    }
  }

  VoidCallback? loginAction(ServiceAuth? auth) {
    if (busy.value) return null;
    return auth == null ? onDone : () => run(auth.login);
  }

  void tokenLogin(ServiceAuth auth) => showTokenLogin(
    context,
    auth,
    onResult: (ok) {
      if (ok && mounted) onDone?.call();
    },
  );

  void switchService() => serviceSwitcher(context);
}
