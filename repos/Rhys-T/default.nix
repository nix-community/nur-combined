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
    
    _Read-Me-link = pkgs.runCommandLocal "___Read_Me___" rec {
        message = ''
        This is not a real package.
        It's just here to add a Read Me link to <https://nur.nix-community.org/repos/rhys-t/>.
        See <${meta.homepage}> for the actual Read Me.
        '';
        meta = {
            homepage = "https://github.com/Rhys-T/nur-packages#readme";
            knownVulnerabilities = [message];
        };
    } ''
        echo -E "$message" >&2
        exit 1
    '';
    
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
    
    bubbros = pkgs.callPackage ./pkgs/bubbros { inherit maintainers; };
    
    flatzebra = pkgs.callPackage ./pkgs/flatzebra { inherit maintainers; };
    burgerspace = pkgs.callPackage ./pkgs/flatzebra/burgerspace.nix { inherit flatzebra maintainers; };
    
    hfsutils = pkgs.callPackage ./pkgs/hfsutils { inherit maintainers; };
    hfsutils-tk = hfsutils.override { enableTclTk = true; };
    
    minivmac36 = pkgs.callPackage ./pkgs/minivmac/36.nix { inherit maintainers; };
    minivmac37 = pkgs.callPackage ./pkgs/minivmac/37.nix { inherit maintainers; };
    minivmac = minivmac36;
    minivmac-unstable = minivmac37;
    
    mame = pkgs.callPackage (pkgs.callPackage ./pkgs/mame {}) {};
    mame-metal = pkgs.callPackage (pkgs.callPackage ./pkgs/mame {}) {
        darwinMinVersion = "11.0";
    };
}
