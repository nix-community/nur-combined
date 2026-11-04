import '../../Utils/Functions/NavigateToScreen.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../Core/Preferences/PrefManager.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../MainScreen.dart';

class LoginState extends ScreenState {
  void enter() {
    PrefName.hasCompletedOnboarding.value = true;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    unawaited(replacePage<void, void>(context, const MainScreen()));
  }
}
