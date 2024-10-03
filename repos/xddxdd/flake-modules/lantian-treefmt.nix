{ treefmt-nix, ... }:
{
  imports = [ treefmt-nix.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      treefmt = {
        flakeFormatter = false;
        projectRootFile = "flake.nix";

        settings = {
          formatter.deadnix.excludes = [ "**/composer2nix/**" ];
          global.excludes = [
            "**/_sources/**"
            "_sources/**"
          ];
        };

        programs = {
          black.enable = true;
          deadnix.enable = true;
          isort.enable = true;
          nixfmt.enable = true;
          statix.enable = true;
        };
      };

      formatter = pkgs.writeShellScriptBin "treefmt-auto" ''
        for i in {1..5}; do
          echo "Running treefmt for the ''${i}th time"
          ${config.treefmt.build.wrapper}/bin/treefmt --clear-cache --fail-on-change "$@" && exit 0
        done
        exit $?
      '';
    };
}
