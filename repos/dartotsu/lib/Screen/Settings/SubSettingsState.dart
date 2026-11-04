import 'package:flutter/widgets.dart';

import '../../Model/Setting.dart';
import '../../Widgets/Components/ScreenState.dart';

class SubSettingsState extends ScreenState {
  final String title;
  final List<Setting> Function(BuildContext) builder;

  SubSettingsState(this.title, this.builder);

  List<Setting> build(BuildContext context) => builder(context);
}
