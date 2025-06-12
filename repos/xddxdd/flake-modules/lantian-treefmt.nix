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
            "**/deps.nix"
          ];
        };

        programs = {
          # # Disabled for not recognizing ARM64 runner
          # actionlint.enable = true;
          black.enable = true;
          deadnix = {
            enable = true;
            no-lambda-arg = true;
            no-lambda-pattern-names = true;
          };
          dos2unix.enable = true;
          # # Disable for build failure
          # formatjson5.enable = true;
          isort.enable = true;
          # # Disable for unable to handle multiple scripts with same name
          # mypy.enable = true;
          nixfmt.enable = true;
          shfmt.enable = true;
          statix.enable = true;
        };

        settings.formatter.dos2unix.excludes = [ "*.reg" ];
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
