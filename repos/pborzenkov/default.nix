{pkgs ? import <nixpkgs> {}}: {
  modules = import ./modules;

  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons {});
  koreader-syncd = pkgs.callPackage ./pkgs/koreader-syncd {};
  orpheusbetter-crawler = pkgs.callPackage ./pkgs/orpheusbetter-crawler {};
  osccopy = pkgs.callPackage ./pkgs/osccopy {};
  tg-bot-skyeng = pkgs.callPackage ./pkgs/tg-bot-skyeng {};
  tg-bot-transmission = pkgs.callPackage ./pkgs/tg-bot-transmission {};
  transmission-exporter = pkgs.callPackage ./pkgs/transmission-exporter {};
  vlmcsd = pkgs.callPackage ./pkgs/vlmcsd {};
}
