{
  pkgs,
  lib ? pkgs.lib,
}:

{
  /*
    Evaluate two NixOS configurations and produce a buildEnv containing
    only the packages that appear in the target but not in the empty
    ("baseline") evaluation.  Returns all intermediates so callers can
    also inspect session variables, fonts, etc.

    Defaults assume `<nur>` and `<nixpkgs>` are present on NIX_PATH.
  */
  mkNixosBuildEnv =
    {
      nixosEval ? import <nixpkgs/nixos/lib/eval-config.nix>,
      specialArgs ? {
        nur = import <nur> {
          inherit pkgs;
          nurpkgs = pkgs;
          repoOverrides = {
            nagy = import ../. { inherit pkgs; };
          };
        };
      },
      targetModules ? [ ],
      name ? "nixos-diff-env",
    }:
    let
      sysEmpty = nixosEval {
        inherit specialArgs;
        modules = [
          { system.stateVersion = "26.05"; }
        ];
      };
      sys = nixosEval {
        inherit specialArgs;
        modules = [
          { system.stateVersion = "26.05"; }
        ]
        ++ targetModules;
      };
      newPkgs = lib.filter (
        pkg: !(lib.elem pkg sysEmpty.config.environment.systemPackages)
      ) sys.config.environment.systemPackages;
      buildEnv = pkgs.buildEnv {
        inherit name;
        paths = newPkgs;
      };
      diffedSessionVariables = lib.filterAttrs (
        name: value:
          !(sysEmpty.config.environment.sessionVariables ? ${name})
          || sysEmpty.config.environment.sessionVariables.${name} != value
      ) sys.config.environment.sessionVariables;
      diffedFontPackages = lib.filter (
        font: !(lib.elem font sysEmpty.config.fonts.packages)
      ) sys.config.fonts.packages;
    in
    {
      inherit
        sysEmpty
        sys
        newPkgs
        buildEnv
        diffedSessionVariables
        diffedFontPackages
        ;
    };
}
