{ pkgs ? import <nixpkgs> { } }:

rec {
  am2rlauncher = pkgs.callPackage ./pkgs/am2rlauncher {};

  avisynthplus = pkgs.callPackage ./pkgs/avisynthplus {};

  avx-palemoon = pkgs.callPackage ./pkgs/avx-palemoon {};

  avx-palemoon-bin = pkgs.callPackage ./pkgs/avx-palemoon/bin.nix {};

  beebeep = pkgs.qt5.callPackage ./pkgs/beebeep {};

  doomseeker-latest = pkgs.qt5.callPackage ./pkgs/doomseeker-latest {};

  flashplayer = pkgs.callPackage ./pkgs/mozilla-plugins/flashplayer {};

  flashplayer-standalone = pkgs.callPackage ./pkgs/mozilla-plugins/flashplayer/standalone.nix {};

  flashplayer-standalone-debugger = flashplayer-standalone.override {
    debug = true;
  };


  glaxnimate = pkgs.qt5.callPackage ./pkgs/glaxnimate {};
  
  ripcord-patched = pkgs.qt5.callPackage ./pkgs/ripcord-patched {};

  ripcord-patcher = pkgs.callPackage ./pkgs/ripcord-patched/ripcord-patcher.nix {};

  funchook = pkgs.callPackage ./pkgs/ripcord-patched/funchook.nix {};

  spiralknights = pkgs.callPackage ./pkgs/spiralknights {};

  zandronum-dev = pkgs.callPackage ./pkgs/zandronum-dev {};

  zandronum-dev-server = zandronum-dev.override {
    serverOnly = true;
  };
}
