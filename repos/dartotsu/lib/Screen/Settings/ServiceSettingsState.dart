import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/State/State.dart';
import '../../Widgets/Components/ScreenState.dart';

class ServiceSettingsState extends ScreenState {
  final MediaService initial;

  ServiceSettingsState(this.initial);

  late final List<MediaService> services = find<MediaServiceController>()
      .services
      .where((s) => s.settingsView != null)
      .toList();

  late final TabController tab = TabController(
    length: services.length,
    vsync: vsync,
    animationDuration: animDuration(300),
    initialIndex: _start < 0 ? 0 : _start,
  );

  int get _start => services.indexWhere((s) => s.id == initial.id);

  bool get hasTabs => services.length >= 2;

  @override
  void onInit() => tab.index;

  @override
  void onClose() => tab.dispose();
}
