{ pkgs ? import <nixpkgs> {}  }:
{
  hyperspec = pkgs.callPackage ./pkgs/hyperspec { } ;

  luaPackages.fennel = pkgs.callPackage ./pkgs/fennel.nix { } ;

  luaPackages.tl = pkgs.callPackage ./pkgs/teal.nix { } ;

  schemaorg = pkgs.callPackage ./pkgs/schemaorg { } ;

  passphrase2pgp = pkgs.callPackage ./pkgs/passphrase2pgp.nix {};

  apertium = pkgs.callPackage ./pkgs/apertium.nix {};

  lttoolbox = pkgs.callPackage ./pkgs/lttoolbox.nix {};

  ruffle = pkgs.callPackage ./pkgs/ruffle {};

  lunasvg = pkgs.callPackage ./pkgs/lunasvg.nix {};

  lispPackages.vacietis = pkgs.callPackage ./pkgs/vacietis {};

}
