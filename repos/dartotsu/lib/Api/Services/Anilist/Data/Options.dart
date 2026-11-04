import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

const kAnilistTitleLanguages = {
  'ENGLISH': 'English',
  'ROMAJI': 'Romaji',
  'NATIVE': 'Native',
};

const kAnilistStaffLanguages = {
  'ROMAJI_WESTERN': 'Romaji, Western Order (Killua Zoldyck)',
  'ROMAJI': 'Romaji (Zoldyck Killua)',
  'NATIVE': 'Native (キルア=ゾルディック)',
};

Map<String, String> get kAnilistRowOrders => {
  'score': getString.orderScore,
  'title': getString.orderTitle,
  'updatedAt': getString.orderLastUpdated,
  'id': getString.orderLastAdded,
};

Map<int, String> get kAnilistMergeTimes => {
  0: getString.never,
  30: getString.minutesCount(30),
  60: getString.hoursCount(1),
  120: getString.hoursCount(2),
  180: getString.hoursCount(3),
  360: getString.hoursCount(6),
  720: getString.hoursCount(12),
  1440: getString.daysCount(1),
  2880: getString.daysCount(2),
  4320: getString.daysCount(3),
  10080: getString.weeksCount(1),
  20160: getString.weeksCount(2),
  29160: getString.always,
};

const kAnilistTimezones = [
  '(GMT-11:00) Pago Pago',
  '(GMT-10:00) Hawaii Time',
  '(GMT-09:00) Alaska Time',
  '(GMT-08:00) Pacific Time',
  '(GMT-07:00) Mountain Time',
  '(GMT-06:00) Central Time',
  '(GMT-05:00) Eastern Time',
  '(GMT-04:00) Atlantic Time - Halifax',
  '(GMT-03:00) Sao Paulo',
  '(GMT-02:00) Mid-Atlantic',
  '(GMT-01:00) Azores',
  '(GMT+00:00) London',
  '(GMT+01:00) Berlin',
  '(GMT+02:00) Helsinki',
  '(GMT+03:00) Istanbul',
  '(GMT+04:00) Dubai',
  '(GMT+04:30) Kabul',
  '(GMT+05:00) Maldives',
  '(GMT+05:30) India Standard Time',
  '(GMT+05:45) Kathmandu',
  '(GMT+06:00) Dhaka',
  '(GMT+06:30) Cocos',
  '(GMT+07:00) Bangkok',
  '(GMT+08:00) Hong Kong',
  '(GMT+08:30) Pyongyang',
  '(GMT+09:00) Tokyo',
  '(GMT+09:30) Central Time - Darwin',
  '(GMT+10:00) Eastern Time - Brisbane',
  '(GMT+10:30) Central Time - Adelaide',
  '(GMT+11:00) Eastern Time - Melbourne, Sydney',
  '(GMT+12:00) Nauru',
  '(GMT+13:00) Auckland',
  '(GMT+14:00) Kiritimati',
];

String anilistTimezoneApi(String display) {
  final m = RegExp(r'\(GMT([+-])(\d{2}):(\d{2})\)').firstMatch(display);
  if (m == null) return '00:00';
  return '${m[1] == '-' ? '-' : ''}${m[2]}:${m[3]}';
}

String? anilistTimezoneLabel(String? api) {
  final parts = api?.split(':');
  if (parts == null || parts.length != 2) return null;
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  final negative = parts[0].startsWith('-');
  final needle =
      '(GMT${negative ? '-' : '+'}'
      '${hours.abs().toString().padLeft(2, '0')}:'
      '${minutes.abs().toString().padLeft(2, '0')})';
  for (final zone in kAnilistTimezones) {
    if (zone.startsWith(needle)) return zone;
  }
  return null;
}
