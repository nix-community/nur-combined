{
  pkgs ? import <nixpkgs> { },
}:
{
  modules = import ./modules;

  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });
  koreader-syncd = pkgs.callPackage ./pkgs/koreader-syncd { };
  osccopy = pkgs.callPackage ./pkgs/osccopy { };
  tg-bot-skyeng = pkgs.callPackage ./pkgs/tg-bot-skyeng { };
  transmission-exporter = pkgs.callPackage ./pkgs/transmission-exporter { };
  vlmcsd = pkgs.callPackage ./pkgs/vlmcsd { };
}
