{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt;
          priority = 0;
        };
        programs.statix = {
          enable = true;
          priority = 1;
        };
        programs.deadnix = {
          enable = true;
          priority = 2;
        };
        programs.prettier.enable = true;
        programs.just.enable = true;
        programs.toml-sort.enable = true;
        programs.shfmt.enable = true;
      };
    };
}
