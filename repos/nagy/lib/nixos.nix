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

      # Fontconfig state of the target system.  Used to imitate the target
      # font setup from a shell, without `nixos-rebuild switch`.
      fontconfigEnable = sys.config.fonts.fontconfig.enable;
      fontconfigEtc = lib.optionalString fontconfigEnable sys.config.environment.etc.fonts.source;
      fontsConf =
        if fontconfigEnable then
          pkgs.makeFontsConf {
            fontDirectories = sys.config.fonts.packages;
            # Impure host font directories break the imitation.
            impureFontDirectories = [ ];
            includes = [ "${fontconfigEtc}/conf.d" ];
          }
        else
          null;
      fontsCheck =
        if fontconfigEnable then
          pkgs.writeShellApplication {
            name = "fonts-check";
            runtimeInputs = [ pkgs.fontconfig ];
            text = ''
              # Pin the examined config.  Do not inherit from the caller.
              export FONTCONFIG_FILE=${fontsConf}
              export FONTCONFIG_PATH=${fontconfigEtc}

              # Fontconfig 2.18 conf.avail files use xsi:nil without a namespace
              # declaration.  The host library rejects the attribute and prints
              # a warning for each occurrence.
              quiet() {
                grep -v -e '^Fontconfig warning' -e '^Fontconfig error: Cannot load default config file' || true
              }

              echo "FONTCONFIG_FILE=$FONTCONFIG_FILE"
              echo "FONTCONFIG_PATH=$FONTCONFIG_PATH"
              echo

              echo "== config files in effect"
              fc-conflist 2>&1 | quiet | grep -E '^\+' || true
              echo

              echo "== generic families"
              for family in sans-serif serif monospace emoji; do
                printf '%-12s %s\n' "$family" "$(fc-match "$family" 2>&1 | quiet)"
              done

              if [ "$#" -gt 0 ]; then
                echo
                echo "== requested families"
                for family in "$@"; do
                  printf '%-28s %s\n' "$family" "$(fc-match "$family" 2>&1 | quiet)"
                done
              fi
            '';
          }
        else
          null;
    in
    {
      inherit
        sysEmpty
        sys
        newPkgs
        buildEnv
        diffedSessionVariables
        diffedFontPackages
        fontconfigEnable
        fontconfigEtc
        fontsConf
        fontsCheck
        ;
    };
}
