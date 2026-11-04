import 'dart:io';

class Rule {
  final String name;
  final String hint;
  final bool Function(String file, String source, int offset) hit;
  final Pattern pattern;
  final Set<String> allow;

  const Rule(
    this.name,
    this.hint,
    this.pattern,
    this.hit, {
    this.allow = const {},
  });
}

bool always(String file, String source, int offset) => true;

int _close(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    final c = s[i];
    if (c == '(') depth++;
    if (c == ')' && --depth == 0) return i;
  }
  return -1;
}

List<String> _args(String s) {
  final out = <String>[];
  var depth = 0;
  var cur = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if ('([{'.contains(c)) depth++;
    if (')]}'.contains(c)) depth--;
    if (c == ',' && depth == 0) {
      out.add(cur.toString());
      cur = StringBuffer();
    } else {
      cur.write(c);
    }
  }
  if (cur.toString().trim().isNotEmpty) out.add(cur.toString());
  return out;
}

final _physical = RegExp(
  r'\.(left|right)\b|MediaQuery|viewPadding|viewInsets|\bpadding\b',
);
final _static = RegExp(r'^\s*(-?\d+(\.\d+)?|Dimens\.\w+|\d+\.\w+\(\))\s*$');

String _call(String s, int at, String prefix) {
  final open = at + prefix.length - 1;
  final close = _close(s, open);
  return close < 0 ? '' : s.substring(open + 1, close);
}

bool _insetsOnly(String file, String s, int at) {
  final inner = _call(s, at, 'EdgeInsets.only(');
  if (_physical.hasMatch(inner)) return false;
  return RegExp(r'\b(left|right)\s*:').hasMatch(inner);
}

bool _fromLtrb(String file, String s, int at) {
  final inner = _call(s, at, 'EdgeInsets.fromLTRB(');
  final args = _args(inner);
  return args.length == 4 &&
      args[0].trim() != args[2].trim() &&
      !_physical.hasMatch(inner);
}

bool _positioned(String file, String s, int at) {
  final inner = _call(s, at, 'Positioned(');
  for (final a in _args(inner)) {
    final m = RegExp(r'^\s*(left|right)\s*:(.*)$', dotAll: true).firstMatch(a);
    if (m != null && _static.hasMatch(m.group(2)!)) return true;
  }
  return false;
}

bool _radius(String file, String s, int at) {
  final head = s.substring(at, (at + 160).clamp(0, s.length));
  return RegExp(
    r'\b(left|right|topLeft|topRight|bottomLeft|bottomRight)\s*:',
  ).hasMatch(head);
}

final rules = <Rule>[
  Rule(
    'rtl: EdgeInsets.only(left/right)',
    'EdgeInsetsDirectional.only(start/end)',
    RegExp(r'(?<![A-Za-z])EdgeInsets\.only\('),
    _insetsOnly,
  ),
  Rule(
    'rtl: EdgeInsets.fromLTRB (asymmetric)',
    'EdgeInsetsDirectional.fromSTEB',
    RegExp(r'(?<![A-Za-z])EdgeInsets\.fromLTRB\('),
    _fromLtrb,
  ),
  Rule(
    'rtl: Alignment left/right',
    'AlignmentDirectional.*Start/End',
    RegExp(
      r'(?<![A-Za-z])Alignment\.(centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)\b',
    ),
    always,
  ),
  Rule(
    'rtl: Positioned(left/right)',
    'PositionedDirectional(start/end)',
    RegExp(r'(?<![A-Za-z])Positioned\('),
    _positioned,
  ),
  Rule(
    'rtl: BorderRadius left/right',
    'BorderRadiusDirectional',
    RegExp(r'(?<![A-Za-z])BorderRadius\.(only|horizontal)\('),
    _radius,
  ),
  Rule(
    'rtl: Border(left/right)',
    'BorderDirectional',
    RegExp(r'(?<![A-Za-z])Border\((?=[^)]*\b(left|right)\s*:)'),
    always,
  ),
  Rule(
    'rtl: TextAlign.left/right',
    'TextAlign.start/end',
    RegExp(r'TextAlign\.(left|right)\b'),
    always,
  ),
  Rule(
    'navigation: raw route push',
    'navigateToPage / replacePage',
    RegExp(r'MaterialPageRoute|Navigator\.of\([^)]*\)\.push\('),
    always,
    allow: {
      'Utils/Functions/NavigateToScreen.dart',
      'Core/NetworkManager/NetworkManager.dart',
      'Screen/Error/ErrorScreen.dart',
      'Screen/Error/ErrorState.dart',
    },
  ),
  Rule(
    'sheets: raw bottom sheet / dialog',
    'showCustomBottomDialog / AlertDialogBuilder',
    RegExp(r'showModalBottomSheet|\bshowDialog\b|showAdaptiveDialog'),
    always,
    allow: {'Widgets/Components/CustomBottomDialog.dart'},
  ),
  Rule(
    'paths: path_provider',
    'StorageManager',
    RegExp(
      r'getApplicationDocumentsDirectory|getTemporaryDirectory|getApplicationSupportDirectory',
    ),
    always,
    allow: {
      'Core/Preferences/StorageManager.dart',
      'Core/ThemeManager/CustomFontLoader.dart',
    },
  ),
  Rule(
    'text: TextStyle with a font size',
    'context.textTheme.<scale>?.copyWith',
    RegExp(r'TextStyle\([^)]*fontSize'),
    always,
    allow: {
      'main.dart',
      'Core/ThemeManager/',
      'Widgets/Charts/',
      'Screen/Social/Stories/',
      'Screen/Player/Components/PlayerSubtitleView.dart',
      'Screen/Share/ShareCard.dart',
      'Screen/Error/ErrorScreen.dart',
      'Screen/Player/Components/MpvSheets.dart',
    },
  ),
  Rule(
    'snackbars: ScaffoldMessenger',
    'snackString',
    RegExp(r'ScaffoldMessenger|Get\.snackbar'),
    always,
  ),
  Rule(
    'chrome: bare AppBar / TabBar',
    'AppScreenBar / AppTabs',
    RegExp(r'(?<![A-Za-z])(AppBar|TabBar)\('),
    always,
    allow: {
      'Widgets/Components/AppBars.dart',
      'Widgets/Components/AppTabs.dart',
      'Screen/Webview/WebView.dart',
    },
  ),
];

String _lineOf(String s, int offset) =>
    '${s.substring(0, offset).split('\n').length}';

void main(List<String> args) {
  final root = Directory(args.isNotEmpty ? args.first : 'lib');
  var total = 0;
  final byRule = <String, List<String>>{};
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll('\\', '/');
    if (path.contains('/l10n/')) continue;
    final source = entity.readAsStringSync();
    for (final rule in rules) {
      if (rule.allow.any(path.contains)) continue;
      for (final m in rule.pattern.allMatches(source)) {
        if (!rule.hit(path, source, m.start)) continue;
        byRule
            .putIfAbsent(rule.name, () => [])
            .add('$path:${_lineOf(source, m.start)}');
        total++;
      }
    }
  }
  for (final rule in rules) {
    final found = byRule[rule.name];
    if (found == null) continue;
    stdout.writeln('${rule.name}  ->  ${rule.hint}');
    for (final f in found) {
      stdout.writeln('  $f');
    }
  }
  stdout.writeln(
    total == 0 ? 'consistency: ok' : 'consistency: $total issue(s)',
  );
  exit(total == 0 ? 0 : 1);
}
