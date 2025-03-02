# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{ pkgs ? import <nixpkgs> { } }: rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules

  FAE_Linux = pkgs.callPackage ./pkgs/FAE_Linux { };
  SonixFlasherC = pkgs.callPackage ./pkgs/SonixFlasherC { };
  afterglow-cursors-recolored-custom = pkgs.callPackage ./pkgs/afterglow-cursors-recolored-custom { };
  epson_201310w = pkgs.callPackage ./pkgs/epson_201310w { };
  gruvbox-wallpapers = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/gruvbox-wallpapers { });
  python312Packages = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/python312Packages { });
  tssp-resources = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/turing-smart-screen-python/resources { });
  turing-smart-screen-python = pkgs.python312Packages.callPackage ./pkgs/turing-smart-screen-python {
    inherit (python312Packages) pyamdgpuinfo gputil-mathoudebine;
  };
}
