{ lib, pkgs, ... }:
let
  inherit (lib) mapAttrs;
in {
  subcommands.options = {
    subcommands = mapAttrs (k: v: {
      allowExtraArguments = true;
      action.bash = ''
        cd "$NIXCFG_ROOT_PATH"
        attrs=""
        while [ ! $# == 0 ]; do
          if [ ! -z "$attrs" ]; then
            attrs="$attrs."
          fi
          attrs="$attrs$1"
          shift
        done
        if which nix-option > /dev/null 2> /dev/null; then
          nix-option --flake ".#${v}" "$attrs"
        else
          echo "nix-option is not installed"
          exit 1
        fi
      '';
    }) {
      riverwood = "nixosConfigurations.riverwood";
      whiterun = "nixosConfigurations.whiterun";
    };
  };
}
