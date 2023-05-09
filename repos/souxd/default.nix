{ pkgs ? import <nixpkgs> { } }:

rec {
  beebeep = pkgs.qt5.callPackage ./pkgs/beebeep {};

  glaxnimate = pkgs.qt5.callPackage ./pkgs/glaxnimate {};

  am2rlauncher = pkgs.callPackage ./pkgs/am2rlauncher {};

  spiralknights = pkgs.callPackage ./pkgs/spiralknights {};

  palemoon-avx = pkgs.callPackage ./pkgs/palemoon-avx {};

  doomseeker-latest = pkgs.qt5.callPackage ./pkgs/doomseeker-latest {};

  zandronum-beta = pkgs.callPackage ./pkgs/zandronum-beta {};

  zandronum-beta-server = zandronum-beta.override {
    serverOnly = true;
  };

  avisynthplus = pkgs.callPackage ./pkgs/avisynthplus {};
  
  flashplayer = pkgs.callPackage ./pkgs/mozilla-plugins/flashplayer {};

  flashplayer-standalone = pkgs.callPackage ./pkgs/mozilla-plugins/flashplayer/standalone.nix {};

  flashplayer-standalone-debugger = flashplayer-standalone.override {
    debug = true;
  };
}
