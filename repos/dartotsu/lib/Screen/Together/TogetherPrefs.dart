import '../../Core/Preferences/PrefManager.dart';

class TogetherPref {
  TogetherPref._();

  static const backend = Pref(
    'togetherBackend',
    'syncplay',
    PrefLocation.OTHER,
  );
  static const name = Pref('togetherName', '', PrefLocation.OTHER);
  static const guest = Pref('togetherGuest', '', PrefLocation.OTHER);
}
