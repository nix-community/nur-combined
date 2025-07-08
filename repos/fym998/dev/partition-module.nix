{
  inputs,
  ...
}:
{
  debug = true;
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
      treefmt.programs = {
        nixfmt.enable = true;
        statix.enable = true;
      };
      pre-commit.settings.hooks.treefmt = {
        enable = true;
        packageOverrides.treefmt = config.treefmt.build.wrapper;
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
              ;
          };
        };
      };
    };
}
