{ pkgs, sources ? pkgs.callPackage ./_sources/generated.nix { } }:

let
  inherit (pkgs) lib newScope;
in

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  ({
    sources = callPackage ./_sources/generated.nix { };
    updater = callPackage ./updater { };

    activate-dpt = callPackage ./activate-dpt { };
    canokey-udev-rules = callPackage ./canokey-udev-rules { };
    clash-for-windows = callPackage ./clash-for-windows { };
    clash-premium = callPackage ./clash-premium { };
    commit-notifier = callPackage ./commit-notifier { };
    dot-tar = callPackage ./dot-tar { };
    dpt-rp1-py = callPackage ./dpt-rp1-py { };
    fishPlugins = lib.recurseIntoAttrs (callPackage ./fish-plugins {
      inherit (pkgs.fishPlugins) buildFishPlugin;
      pkgsFishPlugins = pkgs.fishPlugins;
    });
    icalingua = callPackage ./icalingua { };
    telegram-send = callPackage ./telegram-send { };
    trojan = callPackage ./trojan { };
    vlmcsd = callPackage ./vlmcsd { };
    wemeet = callPackage ./wemeet { };
  } // lib.optionalAttrs (! (pkgs ? godns)) {
    godns = callPackage ./godns { };
  })
)
