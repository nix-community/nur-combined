{ pkgs, sources ? pkgs.callPackage ./_sources/generated.nix { } }:

{
  activate-dpt = pkgs.callPackage ./activate-dpt { };
  clash-for-windows = pkgs.callPackage ./clash-for-windows { inherit sources; };
  clash-premium = pkgs.callPackage ./clash-premium { inherit sources; };
  commit-notifier = pkgs.callPackage ./commit-notifier { inherit sources; };
  dpt-rp1-py = pkgs.callPackage ./dpt-rp1-py { inherit sources; };
  godns = pkgs.callPackage ./godns { inherit sources; };
  icalingua = pkgs.callPackage ./icalingua { inherit sources; };
  telegram-send = pkgs.callPackage ./telegram-send { inherit sources; };
  trojan = pkgs.callPackage ./trojan { inherit sources; };
  # updater = pkgs.callPackage ./updater { }; # only include updater in flake
  vlmcsd = pkgs.callPackage ./vlmcsd { inherit sources; };
  wemeet = pkgs.callPackage ./wemeet { inherit sources; };
}
