{
  pkgs,
  overrides ? {},
  ...
} @ args: let
  drvAttrs = builtins.removeAttrs args ["pkgs" "overrides"];
  mkSbtDerivation = import ./lib/bootstrap.nix pkgs;
in
  (mkSbtDerivation.withOverrides overrides) drvAttrs
