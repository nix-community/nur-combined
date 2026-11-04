import 'package:flutter/material.dart';

import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../../../../Widgets/Components/ScreenState.dart';
import '../Auth.dart';
import '../Data/User.dart';

class CustomListsState extends ScreenState {
  final bool anime;

  CustomListsState(this.anime);

  late final List<String> saved = _current();
  late final names = saved
      .map((n) => TextEditingController(text: n))
      .toList()
      .liveList;
  final busy = false.live;

  String get title =>
      getString.labelCustomLists(anime ? getString.anime : getString.manga);

  List<String> _current() {
    final user = anilistAuth.user.value as AnilistUser?;
    return List.of(
      (anime ? user?.animeCustomLists : user?.mangaCustomLists) ??
          const <String>[],
    );
  }

  @override
  void onClose() {
    for (final c in names) {
      c.dispose();
    }
  }

  void add() => names.add(TextEditingController());

  Future<void> remove(int index) async {
    final name = names[index].text.trim();
    if (name.isNotEmpty && saved.contains(name)) {
      busy.value = true;
      final ok = await anilistAuth.mutations.deleteCustomList(
        name,
        anime: anime,
      );
      busy.value = false;
      if (!ok) {
        snackString(getString.customListDeleteFailed);
        return;
      }
      saved.remove(name);
      await anilistAuth.refreshUser();
    }
    if (!mounted) return;
    names.removeAt(index).dispose();
  }

  Future<void> save() async {
    final entries = {
      for (final c in names)
        if (c.text.trim().isNotEmpty) c.text.trim(),
    }.toList();
    busy.value = true;
    final ok = await anilistAuth.mutations.updateCustomLists(
      anime: anime ? entries : null,
      manga: anime ? null : entries,
    );
    busy.value = false;
    if (!ok) {
      snackString(getString.customListsSaveFailed);
      return;
    }
    await anilistAuth.refreshUser();
    snackString(getString.customListsSaved);
    pop();
  }
}
