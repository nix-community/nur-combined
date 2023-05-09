{ pkgs ? import <nixpkgs> { } }:

rec {
  beebeep = pkgs.qt5.callPackage ./pkgs/beebeep {};

  glaxnimate = pkgs.qt5.callPackage ./pkgs/glaxnimate {};

  am2rlauncher = pkgs.callPackage ./pkgs/am2rlauncher {};

  spiralknights = pkgs.callPackage ./pkgs/spiralknights {};

  avx-palemoon = pkgs.callPackage ./pkgs/avx-palemoon {};

  avx-palemoon-bin = pkgs.callPackage ./pkgs/avx-palemoon/bin.nix {};

  doomseeker-latest = pkgs.qt5.callPackage ./pkgs/doomseeker-latest {};

  zandronum-dev = pkgs.callPackage ./pkgs/zandronum-dev {};

  zandronum-dev-server = zandronum-dev.override {
    serverOnly = true;
  };

  avisynthplus = pkgs.callPackage ./pkgs/avisynthplus {};
  
  flashplayer = pkgs.callPackage ./pkgs/mozilla-plugins/flashplayer {};

  flashplayer-standalone = pkgs.callPackage ./pkgs/mozilla-plugins/flashplayer/standalone.nix {};

  flashplayer-standalone-debugger = flashplayer-standalone.override {
    debug = true;
  };
}
