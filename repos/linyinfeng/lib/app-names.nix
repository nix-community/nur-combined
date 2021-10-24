{ lib }:

let
  trivial = p: {
    "${p}" = {
      "${p}" = p;
    };
  };
  merge = lib.fold lib.recursiveUpdate { };
  appNamesDict = merge [
    (trivial "activate-dpt")
    { "clash-for-windows" = { "clash-for-windows" = "cfw"; }; }
    (trivial "clash-premium")
    (trivial "commit-notifier")
    (trivial "dot-tar")
    { "dpt-rp1-py" = { "dpt-rp1-py" = "dptrp1"; }; }
    (trivial "godns")
    (trivial "icalingua")
    (trivial "telegram-send")
    (trivial "trojan")
    (trivial "updater")
    (trivial "vlmcsd")
    { "wemeet" = { "wemeet" = "wemeetapp"; }; }
  ];
in
p: appNamesDict.${p} or { }
