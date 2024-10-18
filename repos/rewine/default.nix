{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:
with pkgs; rec {
  cmd-markdown = pkgs.callPackage ./pkgs/cmd-markdown { };
  aliyunpan = pkgs.callPackage ./pkgs/aliyunpan { };
  electron-netease-cloud-music = pkgs.callPackage ./pkgs/electron-netease-cloud-music { };
  graphbuilder = pkgs.callPackage ./pkgs/graphbuilder { };
  landrop = pkgs.callPackage ./pkgs/landrop { };
  lx-music-desktop = pkgs.callPackage ./pkgs/lx-music-desktop { };
  nextssh = pkgs.callPackage ./pkgs/nextssh { };
  ttf-ms-win10 = pkgs.callPackage ./pkgs/ttf-ms-win10 { };
  ttf-wps-fonts = pkgs.callPackage ./pkgs/ttf-wps-fonts { };
  typora-legacy = pkgs.callPackage ./pkgs/typora-legacy { };
  wiliwili = pkgs.callPackage ./pkgs/wiliwili { };
  wldbg = pkgs.callPackage ./pkgs/wldbg { };
  wlhax = pkgs.callPackage ./pkgs/wlhax { };
  ukui-interface = pkgs.libsForQt5.callPackage ./pkgs/ukui-interface { };
  libkysdk-base = pkgs.libsForQt5.callPackage ./pkgs/libkysdk-base { };
  #libkysdk-applications = pkgs.libsForQt5.callPackage ./pkgs/libkysdk-applications { inherit libkysdk-base; };
  #peony = pkgs.libsForQt5.callPackage ./pkgs/peony { inherit ukui-interface; };
  #mogan = pkgs.libsForQt5.callPackage ./pkgs/mogan {  };
  nowide = pkgs.callPackage ./pkgs/nowide {  };
  kylin-virtual-keyboard = libsForQt5.callPackage ./pkgs/kylin-virtual-keyboard { };
  #kylin-wayland-compositor = pkgs.callPackage ./pkgs/kylin-wayland-compositor { };
  xcursor-viewer = pkgs.callPackage ./pkgs/xcursor-viewer { };
}
