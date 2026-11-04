import '../../Core/Preferences/PrefManager.dart';
import '../../Core/State/State.dart';
import 'ScreenState.dart';

class HomeLayoutState extends ScreenState {
  final Pref<Map<String, bool>> pref;

  HomeLayoutState(this.pref);

  late final entries = pref.value.entries
      .map((e) => MapEntry(e.key, e.value))
      .toList()
      .liveList;

  void _save() {
    pref.rx.value = {for (final e in entries) e.key: e.value};
  }

  void toggle(int index, bool value) {
    entries[index] = MapEntry(entries[index].key, value);
    _save();
  }

  void reorder(int from, int to) {
    final target = to > from ? to - 1 : to;
    entries.insert(target, entries.removeAt(from));
    _save();
  }
}
