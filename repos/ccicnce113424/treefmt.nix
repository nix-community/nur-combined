{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt = {
          enable = true;
          priority = 0;
        };
        programs.deadnix = {
          enable = true;
          priority = 1;
        };
        programs.nixf-diagnose = {
          enable = true;
          priority = 2;
          ignore = [ "sema-primop-overridden" ];
        };
        programs.prettier.enable = true;
        programs.just.enable = true;
        programs.toml-sort.enable = true;
        programs.shfmt.enable = true;
      };
    };
}
