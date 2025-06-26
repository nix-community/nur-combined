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
          package = pkgs.nixfmt-rfc-style;
        };
        programs.deadnix.enable = true;
        programs.statix.enable = true;
        programs.prettier.enable = true;
        programs.just.enable = true;
        programs.toml-sort.enable = true;
        programs.shfmt.enable = true;
      };
    };
}
