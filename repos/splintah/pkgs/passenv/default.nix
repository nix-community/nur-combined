{ pkgs, passenv-overlay }:
with { inherit (pkgs.lib) fix extends; };
let
  # Manually apply the passenv overlay to the pkgs argument.
  pkgs' = fix (extends passenv-overlay (_: pkgs));
  haskellPackages' = fix (extends
    pkgs'.haskell.packageOverrides
    (_: pkgs.haskellPackages));
in
  haskellPackages'.passenv
