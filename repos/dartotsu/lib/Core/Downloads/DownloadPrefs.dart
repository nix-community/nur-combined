import '../Preferences/PrefManager.dart';

const downloadParallelPref = Pref('downloadParallel', 2, PrefLocation.OTHER);
const downloadConnectionsPref = Pref(
  'downloadConnections',
  4,
  PrefLocation.OTHER,
);
const downloadNotifyPref = Pref('downloadNotify', 'live', PrefLocation.OTHER);
const downloadAutoDeletePref = Pref(
  'downloadAutoDelete',
  false,
  PrefLocation.OTHER,
);
const downloadInfoFilePref = Pref(
  'downloadInfoFile',
  false,
  PrefLocation.OTHER,
);
const downloadWifiOnlyPref = Pref(
  'downloadWifiOnly',
  false,
  PrefLocation.OTHER,
);
const downloadMeteredPref = Pref('downloadMetered', false, PrefLocation.OTHER);
const downloadSpeedLimitPref = Pref(
  'downloadSpeedLimit',
  0,
  PrefLocation.OTHER,
);

const repoToolsUnlockedPref = Pref(
  'repoToolsUnlocked',
  false,
  PrefLocation.OTHER,
);
