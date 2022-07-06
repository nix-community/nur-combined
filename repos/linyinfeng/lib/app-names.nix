{ lib }:

let
  trivial = p: {
    "${p}" = {
      "${p}" = p;
    };
  };
  empty = p: { "${p}" = { }; };
  merge = lib.fold lib.recursiveUpdate { };
  appNamesDict = merge [
    (trivial "activate-dpt")
    (empty "canokey-udev-rules")
    (trivial "cf-terraforming")
    { "clash-for-windows" = { "clash-for-windows" = "cfw"; }; }
    (trivial "clash-premium")
    (trivial "commit-notifier")
    (trivial "dot-tar")
    { "dpt-rp1-py" = { "dpt-rp1-py" = "dptrp1"; }; }
    (empty "fishPlugins/bang-bang")
    (empty "fishPlugins/git")
    (empty "fishPlugins/replay")
    (trivial "icalingua-plus-plus")
    (trivial "nvfetcher-changes")
    (trivial "nvfetcher-changes-commit")
    (trivial "telegram-send")
    (trivial "trojan")
    (trivial "updater")
    (trivial "vlmcsd")
    {
      "wemeet" = {
        "wemeet" = "wemeetapp";
        "wemeet-force-x11" = "wemeetapp-force-x11";
      };
    }
    (empty "yacd")
    (trivial "zeronsd")
  ];
in
p: appNamesDict.${p}
