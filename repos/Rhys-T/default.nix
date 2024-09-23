# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
    
    maintainers = import ./maintainers.nix;

    # example-package = pkgs.callPackage ./pkgs/example-package { };
    # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
    # ...
    
    lix-game-packages = pkgs.callPackage ./pkgs/lix-game { inherit maintainers; };
    lix-game = lix-game-packages.game;
    lix-game-server = lix-game-packages.server;
    
    xscorch = pkgs.callPackage ./pkgs/xscorch { inherit maintainers; };
    
    pce = pkgs.callPackage ./pkgs/pce { inherit maintainers; };
    pce-with-unfree-roms = pkgs.callPackage ./pkgs/pce {
        inherit maintainers;
        enableUnfreeROMs = true;
    };
    pce-snapshot = pkgs.callPackage ./pkgs/pce/snapshot.nix { inherit maintainers; };
}
