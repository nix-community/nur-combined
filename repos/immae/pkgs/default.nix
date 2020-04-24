{ pkgs }:
with pkgs;
let
  mylibs = import ../lib { inherit pkgs; };
in
rec {
  sources = import ../nix/sources.nix;
  myEnvironments = callPackage ../environments {};
  boinctui = callPackage ./boinctui {};
  cnagios = callPackage ./cnagios { inherit mylibs; };
  duply = callPackage ./duply {};
  flrn = callPackage ./flrn { inherit mylibs; slang = callPackage ./slang_1 {}; };
  genius = callPackage ./genius {};
  mtop = callPackage ./mtop {};
  muttprint = callPackage ./muttprint {};
  mutt-ics = callPackage ./mutt-ics { inherit mylibs; };
  nagios-cli = callPackage ./nagios-cli { inherit mylibs; };
  nagnu = callPackage ./nagnu { inherit mylibs; };
  note = callPackage ./note {};
  notmuch-python2 = callPackage ./notmuch/notmuch-python { pythonPackages = python2Packages; };
  notmuch-python3 = callPackage ./notmuch/notmuch-python { pythonPackages = python3Packages; };
  notmuch-vim = callPackage ./notmuch/notmuch-vim {};
  openarc = callPackage ./openarc { inherit mylibs; };
  opendmarc = callPackage ./opendmarc { libspf2 = callPackage ./opendmarc/libspf2.nix {}; };
  pg_activity = callPackage ./pg_activity { inherit mylibs; };
  pgloader = callPackage ./pgloader {};
  predixy = callPackage ./predixy { inherit mylibs; };
  rrsync_sudo = callPackage ./rrsync_sudo {};
  telegram-cli = callPackage ./telegram-cli { inherit mylibs; };
  telegram-history-dump = callPackage ./telegram-history-dump { inherit mylibs; };
  telegramircd = callPackage ./telegramircd { inherit mylibs; telethon = callPackage ./telethon_sync {}; };
  terminal-velocity = callPackage ./terminal-velocity {};
  tiv = callPackage ./tiv {};
  unicodeDoc = callPackage ./unicode {};

  cardano = callPackage ./crypto/cardano { inherit mylibs; };
  cardano-cli = callPackage ./crypto/cardano-cli {};
  iota-cli-app = callPackage ./crypto/iota-cli-app { inherit mylibs; };
  sia = callPackage ./crypto/sia {};

  pure-ftpd = callPackage ./pure-ftpd {};
  mpd = (callPackage ./mpd_0_21 {}).mpd;
  mpd-small = (callPackage ./mpd_0_21 {}).mpd-small;

  bitlbee-mastodon = callPackage ./bitlbee-mastodon {};

  composerEnv = callPackage ./composer-env {};
  webapps = callPackage ./webapps { inherit mylibs composerEnv; };

  monitoring-plugins = callPackage ./monitoring-plugins {};
  naemon = callPackage ./naemon { inherit mylibs monitoring-plugins; };
  naemon-livestatus = callPackage ./naemon-livestatus { inherit mylibs naemon; };

  python3PackagesPlus = callPackage ./python-packages {
    python = python3;
    inherit mylibs;
  };
  dovecot_deleted-to-trash = callPackage ./dovecot/plugins/deleted_to_trash {
    inherit mylibs;
  };
  dovecot_fts-xapian = callPackage ./dovecot/plugins/fts_xapian {
    inherit mylibs;
  };

  fiche = callPackage ./fiche { inherit mylibs; };
}
