{ allInputs, vacuRoot, ... }: {
  vacuBuilds = {
    treefmtFinal = {
      aliases = [
        "fmt"
        "treefmt"
      ];
    };
  };
  perSystem =
    { pkgs, ... }:
    let
      treefmtEval = allInputs.treefmt-nix.lib.evalModule pkgs /${vacuRoot}/treefmt.nix;
      pkg = treefmtEval.config.build.wrapper;
    in
    {
      vacuBuildDerivations.treefmtFinal = pkg;
      formatter = pkg;
    };
}
