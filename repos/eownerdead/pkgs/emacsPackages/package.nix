{ pkgs, emacsPackages, ... }:
with pkgs;
{
  eglot-tempel = callPackage ./eglot-tempel {
    inherit (pkgs.emacs.pkgs) trivialBuild eglot tempel;
  };
  eglot-supplements = emacsPackages.callPackage ./eglot-supplements { };
  majutsu = emacsPackages.callPackage ./majutsu { };
  tramp = emacsPackages.tramp.overrideAttrs (old: rec {
    version = "2.8.1.5";
    src = fetchurl {
      url = "https://elpa.gnu.org/packages/tramp-${version}.tar";
      hash = "sha256-/AeRSjwAG3dOZJiVb/g/thN1QhB3d+cMGhqPLmOpMBM=";
    };
  });
}
