{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        programs.prettier.enable = true;
      };

      formatter = config.treefmt.build.wrapper;

      pre-commit = {
        check.enable = true;
        settings.hooks.treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };
        settings.hooks.convco = {
          enable = true;
          stages = [ "commit-msg" ];
        };
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.pre-commit.devShell ];
        packages = [ config.treefmt.build.wrapper ];
      };
    };
}
