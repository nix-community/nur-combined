{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:
with pkgs; rec {
  cmd-markdown = pkgs.callPackage ./pkgs/cmd-markdown { };
  aliyunpan = pkgs.callPackage ./pkgs/aliyunpan { };
  electron-netease-cloud-music = pkgs.callPackage ./pkgs/electron-netease-cloud-music { };
  graphbuilder = pkgs.callPackage ./pkgs/graphbuilder { };
  landrop = pkgs.callPackage ./pkgs/landrop { };
  nextssh = pkgs.callPackage ./pkgs/nextssh { };
  ttf-ms-win10 = pkgs.callPackage ./pkgs/ttf-ms-win10 { };
  ttf-wps-fonts = pkgs.callPackage ./pkgs/ttf-wps-fonts { };
  wldbg = pkgs.callPackage ./pkgs/wldbg { };
  wlhax = pkgs.callPackage ./pkgs/wlhax { };
  ukui-interface = pkgs.libsForQt5.callPackage ./pkgs/ukui-interface { };
  libkysdk-base = pkgs.libsForQt5.callPackage ./pkgs/libkysdk-base { };
  #libkysdk-applications = pkgs.libsForQt5.callPackage ./pkgs/libkysdk-applications { inherit libkysdk-base; };
  #peony = pkgs.libsForQt5.callPackage ./pkgs/peony { inherit ukui-interface; };
  #mogan = pkgs.libsForQt5.callPackage ./pkgs/mogan {  };
  nowide = pkgs.callPackage ./pkgs/nowide {  };
  kylin-virtual-keyboard = libsForQt5.callPackage ./pkgs/kylin-virtual-keyboard { };
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
}
