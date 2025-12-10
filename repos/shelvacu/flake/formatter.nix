{ allInputs, vacuRoot, ... }:
{
  perSystem = { pkgs, ... }: let
    treefmtEval = allInputs.treefmt-nix.lib.evalModule pkgs /${vacuRoot}/treefmt.nix;
    formatter = treefmtEval.config.build.wrapper;
  in {
    inherit formatter;
  };
}
