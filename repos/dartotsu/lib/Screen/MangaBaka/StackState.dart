import 'dart:async';

import '../../Api/Services/MangaBaka/Auth.dart';
import '../../Api/Services/MangaBaka/Data/Community.dart';
import '../../Api/Services/MangaBaka/MangaBakaService.dart';
import '../../Api/Services/MangaBaka/Client.dart';
import '../../Core/Services/MediaServiceController.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Logger.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/ScreenState.dart';

class StackState extends ScreenState {
  final MangaBakaStack seed;

  StackState(this.seed);

  late final stack = seed.live;
  final loading = true.live;
  final failed = false.live;

  MediaService get service => find<MediaServiceController>().services
      .firstWhere((s) => s.id == mangaBakaServiceId);

  @override
  void onInit() => unawaited(load());

  Future<void> load() async {
    loading.value = true;
    failed.value = false;
    try {
      stack.value = await mangaBakaAuth.community.stack(seed.id);
    } catch (e, st) {
      logError('StackState', e, st);
      failed.value = true;
    } finally {
      loading.value = false;
    }
  }

  Future<void> setSaved(bool saved) async {
    if (!mangaBakaAuth.isLoggedIn) {
      snackString(getString.stacksSignIn);
      return;
    }
    try {
      await mangaBakaAuth.community.setSaved(seed.id, saved: saved);
      snackString(
        saved ? getString.stackSavedToast : getString.stackRemovedToast,
      );
    } on MangaBakaException catch (e) {
      snackString(
        e.status == 403
            ? getString.stacksScopeNeeded
            : getString.serviceError(getString.mangaBaka, e.message),
      );
    }
  }
}
