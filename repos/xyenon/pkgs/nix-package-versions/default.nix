{
  haskell,
  haskellPackages,
  source,
}:

haskell.lib.overrideCabal (haskellPackages.callPackage ./cabal2nix.nix { }) (_prevAttrs: {
  version = "0-unstable-${source.date}";
  inherit (source) src;
  enableSeparateBinOutput = true;
  homepage = "https://github.com/lazamar/nix-package-versions";
})
