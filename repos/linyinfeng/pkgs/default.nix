{ lib, newScope, selfLib, fishPlugins, emacsPackages, librime }:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    sources = callPackage ./_sources/generated.nix { };
    devPackages = lib.recurseIntoAttrs (callPackage ./dev-packages {
      selfPackages = self;
      inherit selfLib;
    });

    activate-dpt = callPackage ./activate-dpt { };
    aws-s3-reverse-proxy = callPackage ./aws-s3-reverse-proxy { };
    aws-sigv4-proxy = callPackage ./aws-sigv4-proxy { };
    bird-babel-rtt = callPackage ./bird-babel-rtt { };
    canokey-udev-rules = callPackage ./canokey-udev-rules { };
    cf-terraforming = callPackage ./cf-terraforming { };
    clash-for-windows = callPackage ./clash-for-windows { };
    clash-premium = callPackage ./clash-premium { };
    commit-notifier = callPackage ./commit-notifier { };
    dot-tar = callPackage ./dot-tar { };
    dpt-rp1-py = callPackage ./dpt-rp1-py { };
    emacsPackages = lib.recurseIntoAttrs (callPackage ./emacs-packages {
      emacsPackagesToplevel = emacsPackages;
    });
    fishPlugins = lib.recurseIntoAttrs (callPackage ./fish-plugins {
      fishPluginsToplevel = fishPlugins;
    });
    icalingua-plus-plus = callPackage ./icalingua-plus-plus { };
    matrix-chatgpt-bot = callPackage ./matrix-chatgpt-bot { };
    matrix-media-repo = callPackage ./matrix-media-repo { };
    matrix-qq = callPackage ./matrix-qq { };
    matrix-wechat = callPackage ./matrix-wechat { };
    minio-latest = callPackage ./minio-latest { };
    mstickereditor = callPackage ./mstickereditor { };
    nvfetcher-changes = callPackage ./nvfetcher-changes { };
    nvfetcher-changes-commit = callPackage ./nvfetcher-changes-commit { };
    rimePackagesFor = librime: callPackage ./rime-packages { inherit librime; };
    rimePackages = lib.recurseIntoAttrs (self.rimePackagesFor librime);
    swayosd = callPackage ./swayosd { };
    synapse-s3-storage-provider = callPackage ./synapse-s3-storage-provider { };
    telegram-send = callPackage ./telegram-send { };
    tg-send = callPackage ./tg-send { };
    trojan = callPackage ./trojan { };
    vlmcsd = callPackage ./vlmcsd { };
    wemeet = callPackage ./wemeet { };
    yacd = callPackage ./yacd { };
    zeronsd = callPackage ./zeronsd { };
  }
)
