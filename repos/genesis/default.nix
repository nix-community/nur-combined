# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  maintainers = pkgs.lib.maintainers // import ./maintainers.nix;
  mylib = pkgs.lib // { maintainers = maintainers; };
in
# rec is pretty convinient...
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  #appimage-run = pkgs.callPackage ./pkgs/tools/package-management/appimage-run {}; #82266 #89122
  #appimageTools = pkgs.callPackage ./pkgs/build-support/appimage {}; #82266
  #beremiz = pkgs.callPackage ./pkgs/beremiz {};
  caprice32 = pkgs.callPackage ./pkgs/caprice32 { lib = mylib; };
  colorize = pkgs.callPackage ./pkgs/colorize { lib = mylib; };
  # clocktimer = pkgs.callPackage ./pkgs/clocktimer { lib = mylib; };
  emulicious = pkgs.callPackage ./pkgs/emulicious { lib = mylib; };
  fragments-of-euclid = pkgs.callPackage ./pkgs/fragments-of-euclid { lib = mylib; };
  freediag = pkgs.callPackage ./pkgs/freediag { lib = mylib; };
  # frida-agent-example = pkgs.callPackage ./pkgs/frida-agent-example { lib = mylib; };
  # frida-compile = pkgs.callPackage ./pkgs/frida-compile {};
  gbdk-2020 = pkgs.callPackage ./pkgs/gbdk-2020 { lib = mylib; inherit gbdk-2020-sdcc; };
  gbdk-2020-sdcc = pkgs.callPackage ./pkgs/gbdk-2020-sdcc { lib = mylib; };
  gbdk-n = pkgs.callPackage ./pkgs/gbdk-n { lib = mylib; };
  hdl-dump = pkgs.callPackage ./pkgs/hdl_dump { lib = mylib; };

  hdl-batch-installer = pkgs.callPackage ./pkgs/hdl-batch-installer { lib = mylib; };
  # find a lot of games on https://itch.io/games/free/platform-linux
  hospital-hero = pkgs.callPackage ./pkgs/hospital-hero { lib = mylib; };
  kelftool = pkgs.callPackage ./pkgs/kelftool { lib = mylib; };

  # need to port to imagemagick7 or GraphicsMagick
  # magick2cpc = pkgs.callPackage ./pkgs/magick2cpc { lib = mylib; };
  matiec = pkgs.callPackage ./pkgs/matiec { lib = mylib; };
  microwindows = pkgs.callPackage ./pkgs/microwindows { lib = mylib; };
  mkpsxiso = pkgs.callPackage ./pkgs/mkpsxiso { lib = mylib; };
  # unsecure freeimage
  # navit = pkgs.libsForQt5.callPackage ./pkgs/navit { lib = mylib; };
  # navittom = pkgs.callPackage ./pkgs/navittom {};
  nsntrace = pkgs.callPackage ./pkgs/nsntrace { lib = mylib; };
  ntpbclient = pkgs.callPackage ./pkgs/ntpbclient { lib = mylib; };
  ps2client = pkgs.callPackage ./pkgs/ps2client { lib = mylib; };
  ps2iconsys = pkgs.callPackage ./pkgs/ps2iconsys { lib = mylib; };

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/development/python-modules { }
  );

  scriptcommunicator = pkgs.libsForQt5.callPackage ./pkgs/scriptcommunicator { lib = mylib; };
  # soulseekqt = pkgs.libsForQt5.callPackage ./pkgs/soulseekqt { lib = mylib; };
  # xlink-kai = pkgs.callPackage ./pkgs/xlink-kai { lib = mylib; inherit frida-agent-example frida-tools; };
}
