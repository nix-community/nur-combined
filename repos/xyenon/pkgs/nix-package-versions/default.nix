{ haskellPackages, source }:

(haskellPackages.callPackage ./cabal2nix.nix { }).overrideAttrs (
  _finalAttrs: prevAttrs: {
    version = "0-unstable-${source.date}";
    inherit (source) src;
    meta = prevAttrs.meta // {
      homepage = "https://github.com/lazamar/nix-package-versions";
    };
  }
)
