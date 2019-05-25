{ pkgs }:
with pkgs;
let
  mylibs = import ../lib { inherit pkgs; };
in
rec {
  boinctui = callPackage ../pkgs/boinctui {};
  cnagios = callPackage ../pkgs/cnagios { inherit mylibs; };
  duply = callPackage ../pkgs/duply {};
  flrn = callPackage ../pkgs/flrn { inherit mylibs; slang = callPackage ../pkgs/slang_1 {}; };
  genius = callPackage ../pkgs/genius {};
  mtop = callPackage ../pkgs/mtop {};
  muttprint = callPackage ../pkgs/muttprint {};
  mutt-ics = callPackage ../pkgs/mutt-ics { inherit mylibs; };
  nagios-cli = callPackage ../pkgs/nagios-cli { inherit mylibs; };
  nagnu = callPackage ../pkgs/nagnu { inherit mylibs; };
  note = callPackage ../pkgs/note {};
  notmuch-python2 = callPackage ../pkgs/notmuch/notmuch-python { pythonPackages = python2Packages; };
  notmuch-python3 = callPackage ../pkgs/notmuch/notmuch-python { pythonPackages = python3Packages; };
  notmuch-vim = callPackage ../pkgs/notmuch/notmuch-vim {};
  pg_activity = callPackage ../pkgs/pg_activity { inherit mylibs; };
  pgloader = callPackage ../pkgs/pgloader {};
  telegram-cli = callPackage ../pkgs/telegram-cli { inherit mylibs; };
  telegram-history-dump = callPackage ../pkgs/telegram-history-dump { inherit mylibs; };
  telegramircd = callPackage ../pkgs/telegramircd { inherit mylibs; telethon = callPackage ../pkgs/telethon_sync {}; };
  terminal-velocity = callPackage ../pkgs/terminal-velocity {};
  tiv = callPackage ../pkgs/tiv {};
  unicodeDoc = callPackage ../pkgs/unicode {};

  cardano = callPackage ../pkgs/crypto/cardano { inherit mylibs; };
  iota-cli-app = callPackage ../pkgs/crypto/iota-cli-app { inherit mylibs; };
  sia = callPackage ../pkgs/crypto/sia {};

  pure-ftpd = callPackage ../pkgs/pure-ftpd {};
  mpd = (callPackage ../pkgs/mpd_0_21 {}).mpd;
  mpd-small = (callPackage ../pkgs/mpd_0_21 {}).mpd-small;

  bitlbee-mastodon = callPackage ./bitlbee-mastodon {};

  composerEnv = callPackage ./composer-env {};
  webapps = callPackage ./webapps { inherit mylibs composerEnv private; };

  private = if builtins.pathExists (./. + "/private")
    then import ./private { inherit pkgs; }
    else { webapps = {}; };

  python3PackagesPlus = callPackage ./python-packages {
    python = python3;
    inherit mylibs;
  };
}
