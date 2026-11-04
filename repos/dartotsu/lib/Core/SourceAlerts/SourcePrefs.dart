import '../Preferences/PrefManager.dart';

const sourceAlertsPref = Pref('sourceAlerts', true, PrefLocation.OTHER);
const sourceSkipUnstartedPref = Pref(
  'sourceSkipUnstarted',
  true,
  PrefLocation.OTHER,
);
const sourceSkipUnseenPref = Pref('sourceSkipUnseen', true, PrefLocation.OTHER);
