{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:
with pkgs; rec {
  cmd-markdown = pkgs.callPackage ./pkgs/cmd-markdown { };
  electron-netease-cloud-music = pkgs.callPackage ./pkgs/electron-netease-cloud-music { };
  graphbuilder = pkgs.callPackage ./pkgs/graphbuilder { };
  landrop = pkgs.callPackage ./pkgs/landrop { };
  nextssh = pkgs.callPackage ./pkgs/nextssh { };
  ttf-ms-win10 = pkgs.callPackage ./pkgs/ttf-ms-win10 { };
  ttf-wps-fonts = pkgs.callPackage ./pkgs/ttf-wps-fonts { };
  wldbg = pkgs.callPackage ./pkgs/wldbg { };
  wlhax = pkgs.callPackage ./pkgs/wlhax { };
  wayland-debug = pkgs.callPackage ./pkgs/wayland-debug {
    wayland = pkgs.callPackage ./pkgs/wayland-debug/wayland.nix { };
  };
  #mogan = pkgs.libsForQt5.callPackage ./pkgs/mogan {  };
  nowide = pkgs.callPackage ./pkgs/nowide {  };
  /*kylin-wlroots = pkgs.wlroots_0_17.overrideAttrs (
    old: {
      src = pkgs.fetchgit {
        url = "https://gitee.com/openKylin/wlroots.git";
        rev = "c98b79d2c66989e5439a0ba2acab9aae6bde6bb1";
        hash = "sha256-06IX52vcPASo41qU2QMHYyTJWI4HMjbzEi1Y51oEZ80=";
      };
    }
  );
  kylin-wayland-compositor = pkgs.callPackage ./pkgs/kylin-wayland-compositor {
    inherit kylin-wlroots;
  };*/
  xcursor-viewer = pkgs.callPackage ./pkgs/xcursor-viewer { };
  git-commit-helper = pkgs.callPackage ./pkgs/git-commit-helper { };
  deepin-translation-utils = pkgs.callPackage ./pkgs/deepin-translation-utils { };
  wlanalyze = pkgs.callPackage ./pkgs/wlanalyze { };
}
