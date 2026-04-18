
{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  notctyparser = pkgs.callPackage ./pkgs/notctyparser.nix {};
  appdata = pkgs.callPackage ./pkgs/appdata.nix {};
  adif-io = pkgs.callPackage ./pkgs/adif-io.nix {};

  not1mm = pkgs.callPackage ./pkgs/not1mm.nix { inherit notctyparser appdata adif-io; };
  pywinkeyer = pkgs.callPackage ./pkgs/pywinkeyer.nix {};

  #waveloggate = pkgs.callPackage ./pkgs/waveloggate.nix {};
  wavelogstoat = pkgs.callPackage ./pkgs/wavelogstoat.nix {};


  flog-symbols-ttf = pkgs.callPackage ./pkgs/fonts/flog-symbols.nix { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
