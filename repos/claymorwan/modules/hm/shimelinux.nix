{ lib, pkgs, config, ... }:

let
  cfg = config.programs.shimelinux;
  pkgs-set = pkgs.callPackage ./../.. { };
in
{
  options.programs.shimelinux = {
    enable = lib.mkEnableOption "ShimeLinux";
    package = lib.mkPackageOption pkgs-set "shimelinux" { nullable = true; };
    
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable autostart for ShimeLinux.
        You need to have `xdg.autostart.enable` set to true for this to work.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = lib.mkIf (cfg.package != null) [ cfg.package ];
      sessionVariables._JAVA_AWT_WM_NONREPARENTING = 1;
    };

    xdg.autostart.entries = [
      "${cfg.package}/share/applications/shimelinux.desktop"
    ];
  };
}
