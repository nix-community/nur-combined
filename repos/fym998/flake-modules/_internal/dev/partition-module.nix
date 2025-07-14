{
  inputs,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.make-shell.flakeModules.default
  ];
  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      treefmt = {
        flakeCheck = false;
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          yamlfmt = {
            enable = true;
            excludes = [ ".github/actions/install-nix/action.yml" ];
            settings.formatter = {
              retain_line_breaks = true;
            };
          };
        };
      };
      pre-commit.settings.hooks.treefmt = {
        enable = true;
      };
      make-shells = {
        default = {
          imports =
            builtins.map
              (
                shellModule:
                builtins.intersectAttrs (lib.genAttrs [
                  "buildInputs"
                  "nativeBuildInputs"
                  "propagatedBuildInputs"
                  "propagatedNativeBuildInputs"
                  "shellHook"
                ] (_: null)) shellModule
              )
              [
                config.treefmt.build.devShell
                config.pre-commit.devShell
              ];
          nativeBuildInputs = builtins.attrValues {
            inherit (pkgs)
              nil
              nix-prefetch-git
              nix-fast-build
              nix-eval-jobs

              yaml2json
              jq
              ;
          };
        };
      };
    };
}
