import 'package:flutter/material.dart';

import '../../Widgets/Components/BaseScreen.dart';
import 'LoginView.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'LoginState.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreen<LoginScreen>
    with ScreenStateHost<LoginScreen, LoginState> {
  @override
  LoginState buildState() => LoginState();

  @override
  Widget buildContent(BuildContext context) => LoginView(onDone: state.enter);
}
