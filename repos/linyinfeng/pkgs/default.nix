{ lib, newScope, fishPlugins }:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    sources = callPackage ./_sources/generated.nix { };
    updater = callPackage ./updater { };

    activate-dpt = callPackage ./activate-dpt { };
    aws-s3-reverse-proxy = callPackage ./aws-s3-reverse-proxy { };
    aws-sigv4-proxy = callPackage ./aws-sigv4-proxy { };
    canokey-udev-rules = callPackage ./canokey-udev-rules { };
    cf-terraforming = callPackage ./cf-terraforming { };
    clash-for-windows = callPackage ./clash-for-windows { };
    clash-premium = callPackage ./clash-premium { };
    commit-notifier = callPackage ./commit-notifier { };
    dot-tar = callPackage ./dot-tar { };
    dpt-rp1-py = callPackage ./dpt-rp1-py { };
    fishPlugins = lib.recurseIntoAttrs (callPackage ./fish-plugins {
      inherit (fishPlugins) buildFishPlugin;
    });
    icalingua-plus-plus = callPackage ./icalingua-plus-plus { };
    nvfetcher-changes = callPackage ./nvfetcher-changes { };
    nvfetcher-changes-commit = callPackage ./nvfetcher-changes-commit { };
    telegram-send = callPackage ./telegram-send { };
    trojan = callPackage ./trojan { };
    vlmcsd = callPackage ./vlmcsd { };
    wemeet = callPackage ./wemeet { };
    yacd = callPackage ./yacd { };
    zeronsd = callPackage ./zeronsd { };
  }
)
