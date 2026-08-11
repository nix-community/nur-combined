/*
{
  pkgs,
  overrides ? {},
  ...
} @ args:
*/

let
  # drvAttrs = builtins.removeAttrs args ["pkgs" "overrides"];
  # mkSbtDerivation = import ./src/sbt-derivation/lib/bootstrap.nix pkgs;
  mkSbtDerivation = import ./src/sbt-derivation/lib/sbt-derivation.nix;
in

# (mkSbtDerivation.withOverrides overrides) drvAttrs
mkSbtDerivation
