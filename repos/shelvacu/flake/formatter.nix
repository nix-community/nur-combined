{ allInputs, vacuRoot, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmtEval = allInputs.treefmt-nix.lib.evalModule pkgs /${vacuRoot}/treefmt.nix;
    in
    {
      formatter = treefmtEval.config.build.wrapper;
    };
}
