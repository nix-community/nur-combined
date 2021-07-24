{ pkgs, lib, config, ... }: with lib; let
  hconfig = config;
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
        postLayout = mkOption {
          type = types.lines;
          default = "";
        };
      };
    };
    config = {
      enable = mkDefault true;
      dynamic = {
        postLayout = mkIf hconfig.services.polybar.enable ''
          ${hconfig.systemd.package or pkgs.systemd}/bin/systemctl --user restart polybar.service
        ''; # monitor count might change, also polybar tray can break on bar movement
        nvidia = mkOptionDefault (pkgs.writeShellScript "displayset-${name}-nvidia" ''
          nvidia-settings --assign CurrentMetaMode=${escapeShellArg config.nvidia.metaModes}
          ${config.dynamic.postLayout}
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
