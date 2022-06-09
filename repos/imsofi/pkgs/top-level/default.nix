{ pkgs, ... }:
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ../../lib { inherit pkgs; }; # functions
  modules = import ../../modules; # NixOS modules
  overlays = import ../../overlays; # nixpkgs overlays

  extraPython3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./python-packages.nix { }
  );

  ferium = pkgs.callPackage ../tools/games/minecraft/ferium { };

  packwiz = pkgs.callPackage ../tools/games/minecraft/packwiz { };

  canaille = pkgs.callPackage ../servers/canaille { inherit extraPython3Packages; };

  # some-qt5-package = pkgs.libsForQt5.callPackage ../some-qt5-package { };
  # ...
}
