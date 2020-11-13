{ pkgs, lib, config, ... }: with lib; let
  displayType = { name, config, ... }: {
    imports = singleton ../misc/display.nix;

    options = {
      dynamic = {
        nvidia = mkOption {
          type = types.package;
        };
        xrandr = mkOption {
          type = types.package;
        };
      };
    };
    config = {
      enable = mkDefault true;
      dynamic = {
        nvidia = mkOptionDefault (pkgs.writeShellScript "displayset-${name}-nvidia" ''
          nvidia-settings --assign CurrentMetaMode=${escapeShellArg config.nvidia.metaModes}
        '');
        xrandr = throw "xrandr layout unimplemented";
      };
    };
  };
in {
  options.hardware.display = mkOption {
    type = types.attrsOf (types.submodule displayType);
    default = { };
  };
  config.home.packages = mkMerge (mapAttrsToList (k: display: mkIf display.enable (singleton (pkgs.writeShellScriptBin "displaylayout-${k}" ''
    exec ${if display.nvidia.enable then display.dynamic.nvidia else display.dynamic.xrandr}
  ''))) config.hardware.display);
}
